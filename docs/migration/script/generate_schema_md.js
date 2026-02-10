// generate_schema_md.js
"use strict";

const fs = require("fs");
const path = require("path");
const admin = require("firebase-admin");

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();
const { FieldPath } = admin.firestore;

/* =========================
 * 컬렉션 정의
 * ========================= */
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

const SUBCOLLECTIONS = {
  appointments: ["menus"],
  chatRooms: ["chatMessages"],
  offers: ["designers"],
  reservations: ["menus"],
  users: ["menus", "notificationCenters"],
};

/* =========================
 * 옵션
 * ========================= */
const SAMPLE_DOCS = Number(process.env.SCHEMA_SAMPLE_DOCS || 200);
const MAX_DEPTH = Number(process.env.SCHEMA_MAX_DEPTH || 2);

/* =========================
 * 타입 판별 유틸
 * ========================= */
function looksLikeDynamicIdKey(key) {
  if (/^\d{6,}$/.test(key)) return true;                // 숫자 uid
  if (/^[A-Za-z0-9_-]{15,}$/.test(key)) return true;   // 랜덤 docId
  return false;
}

function baseTypeOf(v) {
  if (v === null || v === undefined) return "null";
  if (v instanceof admin.firestore.Timestamp) return "Timestamp";
  if (v instanceof admin.firestore.GeoPoint) return "GeoPoint";
  if (v instanceof admin.firestore.DocumentReference) return "DocumentReference";
  if (Array.isArray(v)) return "Array";

  const t = typeof v;
  if (t === "string") return "String";
  if (t === "boolean") return "Boolean";
  if (t === "number") return Number.isInteger(v) ? "Int" : "Double";
  if (t === "object") return "Map";
  return "Unknown";
}

/* =========================
 * 스키마 저장 구조
 * field -> { fieldTypes, elemTypes }
 * ========================= */
function ensureField(schemaMap, field) {
  if (!schemaMap.has(field)) {
    schemaMap.set(field, {
      fieldTypes: new Set(),
      elemTypes: new Set(),
    });
  }
  return schemaMap.get(field);
}

function addFieldType(schemaMap, field, type) {
  ensureField(schemaMap, field).fieldTypes.add(type);
}

function addElemType(schemaMap, field, type) {
  ensureField(schemaMap, field).elemTypes.add(type);
}

/* =========================
 * 동적 key Map 판별
 * ========================= */
function shouldCollapseDynamicMapKeys(obj) {
  if (!obj || typeof obj !== "object" || Array.isArray(obj)) return false;
  const keys = Object.keys(obj);
  if (keys.length === 0) return false;

  const dynCnt = keys.filter(looksLikeDynamicIdKey).length;
  return dynCnt / keys.length >= 0.8;
}

/* =========================
 * 객체 스캔
 * ========================= */
function scanObject(schemaMap, dataObj, prefix = "", depth = 0) {
  if (!dataObj || typeof dataObj !== "object") return;

  for (const [k, v] of Object.entries(dataObj)) {
    const fieldPath = prefix ? `${prefix}.${k}` : k;
    const t = baseTypeOf(v);

    /* ---- Array ---- */
    if (t === "Array") {
      addFieldType(schemaMap, fieldPath, "Array");

      for (const e of v) {
        addElemType(schemaMap, fieldPath, baseTypeOf(e));
      }

      if (depth < MAX_DEPTH) {
        const sampleMaps = v.filter((e) => baseTypeOf(e) === "Map").slice(0, 5);
        for (const m of sampleMaps) {
          scanObject(schemaMap, m, `${fieldPath}`, depth + 1);
        }
      }
      continue;
    }

    /* ---- Map ---- */
    if (t === "Map") {
      addFieldType(schemaMap, fieldPath, "Map");

      if (depth < MAX_DEPTH) {
        if (shouldCollapseDynamicMapKeys(v)) {
          const samples = Object.values(v).slice(0, 5);
          for (const sv of samples) {
            if (baseTypeOf(sv) === "Map") {
              scanObject(schemaMap, sv, `${fieldPath}.{uid}`, depth + 1);
            }
          }
        } else {
          scanObject(schemaMap, v, fieldPath, depth + 1);
        }
      }
      continue;
    }

    /* ---- Primitive ---- */
    addFieldType(schemaMap, fieldPath, t);
  }
}

/* =========================
 * 컬렉션 스키마 추출
 * ========================= */
async function sampleCollectionSchema(ref, limit) {
  const schemaMap = new Map();
  const snap = await ref.orderBy(FieldPath.documentId()).limit(limit).get();
  for (const doc of snap.docs) {
    scanObject(schemaMap, doc.data());
  }
  return schemaMap;
}

/* =========================
 * 타입 출력 규칙
 * ========================= */
const KNOWN_TYPES = new Set([
  "String",
  "Boolean",
  "Int",
  "Double",
  "Timestamp",
  "GeoPoint",
  "DocumentReference",
  "Map",
  "Array",
]);

function formatType(info) {
  const hasArray = info.fieldTypes.has("Array");

  if (hasArray) {
    const elemKnown = [...info.elemTypes].filter((t) => KNOWN_TYPES.has(t));
    return elemKnown.length
      ? `Array<${elemKnown.sort().join(" | ")}>`
      : "Array<>";
  }

  const known = [...info.fieldTypes].filter((t) => KNOWN_TYPES.has(t));
  return known.length ? known.sort().join(" | ") : "<>";
}

/* =========================
 * Markdown 변환
 * ========================= */
function schemaToMarkdown(schemaMap) {
  const rows = [...schemaMap.entries()]
    .map(([field, info]) => ({ field, type: formatType(info) }))
    .sort((a, b) => a.field.localeCompare(b.field));

  let md = `| Field | Type |\n|---|---|\n`;
  for (const r of rows) {
    md += `| \`${r.field}\` | ${r.type} |\n`;
  }
  return md;
}

/* =========================
 * 메인
 * ========================= */
async function main() {
  const sections = [];

  for (const c of TOP_COLLECTIONS) {
    console.log(`[TOP] ${c}`);
    const schema = await sampleCollectionSchema(db.collection(c), SAMPLE_DOCS);
    sections.push({
      title: `Collection: ${c}`,
      path: c,
      schema,
    });
  }

  for (const [parent, subs] of Object.entries(SUBCOLLECTIONS)) {
    console.log(`[SUB] ${parent}`);
    const parents = await db
      .collection(parent)
      .orderBy(FieldPath.documentId())
      .limit(50)
      .get();

    for (const sub of subs) {
      const schemaMap = new Map();
      let cnt = 0;

      for (const p of parents.docs) {
        if (cnt >= SAMPLE_DOCS) break;
        const snap = await db
          .collection(parent)
          .doc(p.id)
          .collection(sub)
          .orderBy(FieldPath.documentId())
          .limit(20)
          .get();

        for (const s of snap.docs) {
          scanObject(schemaMap, s.data());
          cnt++;
          if (cnt >= SAMPLE_DOCS) break;
        }
      }

      sections.push({
        title: `Subcollection: ${parent}/${sub}`,
        path: `${parent}/{docId}/${sub}`,
        schema: schemaMap,
      });
    }
  }

  let md = `# Firestore DB Structure\n\n`;
  md += `- GeneratedAt: ${new Date().toISOString()}\n`;
  md += `- SampleDocs: ${SAMPLE_DOCS}\n\n`;
  md += `> Unknown type: <>\n`;
  md += `> Dynamic keys are collapsed as {uid}\n\n`;

  for (const s of sections) {
    md += `## ${s.title}\n`;
    md += `- Path: \`${s.path}\`\n\n`;
    md += s.schema.size ? schemaToMarkdown(s.schema) : "⚠️ No data\n";
    md += `\n`;
  }

  const out = path.resolve(process.cwd(), "firestore_schema.md");
  fs.writeFileSync(out, md, "utf8");
  console.log(`\n✅ DONE: ${out}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
