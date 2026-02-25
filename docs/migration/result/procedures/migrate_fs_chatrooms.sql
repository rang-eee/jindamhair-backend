-- migrate_fs_chatrooms.sql
-- Firestore fs_chatrooms 업무 통합 프로시저 모음

-- migrate_fs_chatrooms_to_tb_chatroom.sql
-- Firestore fs_chatrooms -> tb_chatroom 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_chatrooms_to_tb_chatroom()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_chatroom_chatroom_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_chatroom RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_chatroom (
    chatroom_id,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
      nextval('seq_tb_chatroom_chatroom_id')::text,
    doc_id,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_chatrooms
  ON CONFLICT (chatroom_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom');
END;
$$;

-- =====================================================
-- migrate_fs_chatrooms_to_tb_chatroom_member.sql
-- =====================================================
-- Firestore fs_chatrooms -> tb_chatroom_member 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_chatrooms_to_tb_chatroom_member()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_chatroom_member_chatroom_member_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_chatroom_member RESTART IDENTITY CASCADE;

  WITH base AS (
    SELECT doc_id, data, created_at, updated_at
    FROM fs_chatrooms
  ),
  members_from_infos AS (
    SELECT
      b.doc_id AS chatroom_id,
      COALESCE(m.value->>'uid', m.key) AS uid,
      m.value->>'title' AS chatroom_name,
      fn_safe_timestamp(m.value->>'lastSeenDt') AS last_read_at,
      b.created_at,
      b.updated_at,
      b.data
    FROM base b
    JOIN LATERAL jsonb_each(b.data->'memberInfos') m
      ON jsonb_typeof(b.data->'memberInfos') = 'object'
  ),
  members_from_ids AS (
    SELECT
      b.doc_id AS chatroom_id,
      uid AS uid,
      NULL::text AS chatroom_name,
      NULL::timestamp AS last_read_at,
      b.created_at,
      b.updated_at,
      b.data
    FROM base b
    JOIN LATERAL jsonb_array_elements_text(b.data->'memberIds') AS uid
      ON jsonb_typeof(b.data->'memberIds') = 'array'
  ),
  all_members AS (
    SELECT * FROM members_from_infos
    UNION
    SELECT * FROM members_from_ids
  ),
  normalized AS (
    SELECT
      chatroom_id,
      uid,
      COALESCE(chatroom_name, data->>'title') AS chatroom_name,
      COALESCE(
        last_read_at,
        fn_safe_timestamp(data->'memberRecentSeenById'->>uid)
      ) AS last_read_at,
      created_at,
      updated_at,
      ROW_NUMBER() OVER (
        PARTITION BY chatroom_id, uid
        ORDER BY
          (chatroom_name IS NOT NULL) DESC,
          last_read_at DESC NULLS LAST
      ) AS rn
    FROM all_members
    WHERE uid IS NOT NULL AND uid <> ''
  )
  INSERT INTO jindamhair.tb_chatroom_member (
    chatroom_member_id,
    chatroom_id,
    uid,
    chatroom_name,
    last_read_at,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT DISTINCT
    nextval('seq_tb_chatroom_member_chatroom_member_id')::text AS chatroom_member_id,
    COALESCE(c.chatroom_id, normalized.chatroom_id),
    COALESCE(u.uid, normalized.uid),
    chatroom_name,
    last_read_at,
    normalized.chatroom_id || '_' || normalized.uid,
    COALESCE(normalized.created_at, now()),
    'migration',
    normalized.updated_at,
    'migration',
    'N'
  FROM normalized
  LEFT JOIN jindamhair.tb_chatroom c
    ON c.migration_id = normalized.chatroom_id
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = normalized.uid
  WHERE normalized.rn = 1
  ON CONFLICT (chatroom_member_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom_member');
END;
$$;
