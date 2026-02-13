// migrate.js
"use strict";

const admin = require("firebase-admin");
const { Pool } = require("pg");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});
const db = admin.firestore();
const { FieldPath } = admin.firestore;

const pool = new Pool({ connectionString: process.env.PG_URL });

// ✅ 너가 준 최상위 컬렉션(18개)
const TOP_COLLECTIONS = [
  "alerts",
  "appointments",
  "banners",
  "chatRooms",
  "configuration",
  "dynamicLinks",
  "notifications",
  "offers",
  "payments",
  "pushes",
  "reservations",
  "reviews",
  "statistics",
  "stores",
  "treatmentClassfications",
  "treatments",
  "users",
  "usersFavorites",
];

// ✅ 너가 준 서브컬렉션 구조
// parentCollection -> [subcollectionName...]
const SUBCOLLECTIONS = {
  appointments: ["menus", "sign"],
  chatRooms: ["chatMessages"],
  offers: ["designers"],
  reservations: ["menus"],
  users: ["menus", "notificationCenters"],
};

function uniqueList(items) {
  return Array.from(new Set(items));
}

// 테이블명 변환: fs_{lowercase}
function topTableName(collectionName) {
  // chatRooms -> fs_chatrooms
  return `fs_${collectionName.toLowerCase()}`;
}

// 서브테이블명 변환: fs_{parent}__{sub}
function subTableName(parent, sub) {
  return `fs_${parent.toLowerCase()}__${sub.toLowerCase()}`;
}

// Firestore value -> JSON-safe
function toJsonSafe(v) {
  if (v === null || v === undefined) return v;
  if (v instanceof admin.firestore.Timestamp) return v.toDate().toISOString();
  if (v instanceof admin.firestore.GeoPoint) return { lat: v.latitude, lng: v.longitude };
  if (v instanceof admin.firestore.DocumentReference) return { _ref: v.path };
  if (Array.isArray(v)) return v.map(toJsonSafe);
  if (typeof v === "object") {
    const out = {};
    for (const [k, vv] of Object.entries(v)) out[k] = toJsonSafe(vv);
    return out;
  }
  return v;
}

// created_at / updated_at 후보 키 자동 매핑(문서에 없으면 null)
function pickDate(dataObj, keys) {
  for (const k of keys) {
    const v = dataObj[k];
    if (v instanceof admin.firestore.Timestamp) return v.toDate();
    if (typeof v === "string") {
      const d = new Date(v);
      if (!isNaN(d.getTime())) return d;
    }
  }
  return null;
}

async function upsertTop(collectionName, docId, dataObj) {
  const table = topTableName(collectionName);
  const dataJson = JSON.stringify(toJsonSafe(dataObj));

  // 최상위 테이블 DDL에 created_at/updated_at이 없는 테이블도 있긴 한데,
  // 컬럼이 없으면 SQL이 실패하므로, 테이블별로 컬럼 유무를 맞춰서 쿼리 분기
  const hasCreatedUpdated =
    !["configuration", "dynamiclinks", "statistics", "treatmentclassfications", "treatments", "usersfavorites"].includes(
      collectionName.toLowerCase()
    );

  if (hasCreatedUpdated) {
    const createdAt = pickDate(dataObj, ["createdAt", "created_at", "createAt", "create_at"]);
    const updatedAt = pickDate(dataObj, ["updatedAt", "updated_at", "updateAt", "update_at", "modifiedAt", "modified_at"]);

    const sql = `
      insert into ${table} (doc_id, data, created_at, updated_at)
      values ($1, $2::jsonb, $3, $4)
      on conflict (doc_id) do update set
        data = excluded.data,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at,
        migrated_at = now()
    `;
    await pool.query(sql, [docId, dataJson, createdAt, updatedAt]);
  } else {
    const sql = `
      insert into ${table} (doc_id, data)
      values ($1, $2::jsonb)
      on conflict (doc_id) do update set
        data = excluded.data,
        migrated_at = now()
    `;
    await pool.query(sql, [docId, dataJson]);
  }
}

async function upsertSub(parentCollection, subCollection, parentDocId, subDocId, dataObj) {
  const table = subTableName(parentCollection, subCollection);
  const dataJson = JSON.stringify(toJsonSafe(dataObj));

  // 서브테이블 DDL에 created_at이 있는 건 chatMessages만이라고 가정(네 DDL 기준)
  const hasCreatedAt = (parentCollection === "chatRooms" && subCollection === "chatMessages");

  if (hasCreatedAt) {
    const createdAt = pickDate(dataObj, ["createdAt", "created_at", "createAt", "create_at"]);
    const sql = `
      insert into ${table} (parent_doc_id, doc_id, data, created_at)
      values ($1, $2, $3::jsonb, $4)
      on conflict (parent_doc_id, doc_id) do update set
        data = excluded.data,
        created_at = excluded.created_at,
        migrated_at = now()
    `;
    await pool.query(sql, [parentDocId, subDocId, dataJson, createdAt]);
  } else {
    const sql = `
      insert into ${table} (parent_doc_id, doc_id, data)
      values ($1, $2, $3::jsonb)
      on conflict (parent_doc_id, doc_id) do update set
        data = excluded.data,
        migrated_at = now()
    `;
    await pool.query(sql, [parentDocId, subDocId, dataJson]);
  }
}

async function migrateTopCollection(collectionName, pageSize = 500) {
  console.log(`\n=== TOP ${collectionName} start ===`);
  let lastDoc = null;
  let total = 0;

  while (true) {
    let q = db.collection(collectionName).orderBy(FieldPath.documentId()).limit(pageSize);
    if (lastDoc) q = q.startAfter(lastDoc);

    const snap = await q.get();
    if (snap.empty) break;

    // 배치 트랜잭션(너무 크게 잡지 말기)
    await pool.query("begin");
    try {
      for (const doc of snap.docs) {
        await upsertTop(collectionName, doc.id, doc.data());
        total++;
      }
      await pool.query("commit");
    } catch (e) {
      await pool.query("rollback");
      throw e;
    }

    lastDoc = snap.docs[snap.docs.length - 1];
    console.log(`TOP ${collectionName}: ${total}`);
  }

  console.log(`=== TOP ${collectionName} done. total=${total} ===`);
}

async function migrateSubcollections(parentCollection, subNames, pageSize = 300) {
  console.log(`\n=== SUB ${parentCollection} start ===`);

  // 부모 문서 전체를 스캔하면서 지정된 서브컬렉션만 가져옴
  let lastDoc = null;
  let parentCount = 0;
  let subCount = 0;

  while (true) {
    let q = db.collection(parentCollection).orderBy(FieldPath.documentId()).limit(pageSize);
    if (lastDoc) q = q.startAfter(lastDoc);

    const snap = await q.get();
    if (snap.empty) break;

    for (const parentDoc of snap.docs) {
      parentCount++;
      const parentDocId = parentDoc.id;
      const parentRef = db.collection(parentCollection).doc(parentDocId);

      // 서브컬렉션은 명시된 것만
      for (const subName of subNames) {
        const subRef = parentRef.collection(subName);

        // 서브 문서가 많을 수 있으니 서브도 페이지네이션
        let subLast = null;
        while (true) {
          let sq = subRef.orderBy(FieldPath.documentId()).limit(500);
          if (subLast) sq = sq.startAfter(subLast);

          const subSnap = await sq.get();
          if (subSnap.empty) break;

          await pool.query("begin");
          try {
            for (const subDoc of subSnap.docs) {
              await upsertSub(parentCollection, subName, parentDocId, subDoc.id, subDoc.data());
              subCount++;
            }
            await pool.query("commit");
          } catch (e) {
            await pool.query("rollback");
            throw e;
          }

          subLast = subSnap.docs[subSnap.docs.length - 1];
        }
      }

      if (parentCount % 200 === 0) {
        console.log(`SUB ${parentCollection}: parents=${parentCount}, subdocs=${subCount}`);
      }
    }

    lastDoc = snap.docs[snap.docs.length - 1];
  }

  console.log(`=== SUB ${parentCollection} done. parents=${parentCount}, subdocs=${subCount} ===`);
}

async function truncateAllFsTables() {
  const topTables = TOP_COLLECTIONS.map(topTableName);
  const subTables = Object.entries(SUBCOLLECTIONS)
    .flatMap(([parent, subs]) => subs.map((sub) => subTableName(parent, sub)));
  const tables = uniqueList([...topTables, ...subTables]);

  const sql = `TRUNCATE TABLE ${tables.join(", ")} RESTART IDENTITY CASCADE`;
  console.log("\n=== TRUNCATE FS TABLES START ===");
  await pool.query(sql);
  console.log("=== TRUNCATE FS TABLES DONE ===");
}

async function main() {
  try {
    // 0) 기존 데이터 전체 삭제 후 진행
    await truncateAllFsTables();

    // 1) 최상위 전부
    for (const c of TOP_COLLECTIONS) {
      await migrateTopCollection(c, 500);
    }

    // 2) 서브컬렉션(지정된 것만)
    for (const [parent, subs] of Object.entries(SUBCOLLECTIONS)) {
      await migrateSubcollections(parent, subs, 300);
    }

    console.log("\n✅ ALL DONE");
  } finally {
    await pool.end();
  }
}

main().catch((e) => {
  console.error("❌ FAILED:", e);
  process.exit(1);
});
