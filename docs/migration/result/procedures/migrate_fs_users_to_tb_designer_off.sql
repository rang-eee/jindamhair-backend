-- migrate_fs_users_to_tb_designer_off.sql
-- Firestore fs_users -> tb_designer_off 이관 프로시저 (designerAllCloseTime 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_off()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_designer_off RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_designer_off (
    off_id,
    uid,
    off_at,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    uid || '_' || off_at_text AS off_id,
    uid,
    fn_safe_timestamp(off_at_text) AS off_at,
    COALESCE(fn_safe_timestamp(user_create_at), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM (
    SELECT
      COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) AS uid,
      u.data->>'createAt' AS user_create_at,
      u.created_at,
      u.updated_at,
      off_at_text
    FROM fs_users u
    JOIN LATERAL jsonb_array_elements_text(u.data->'designerAllCloseTime') AS off_at_text
      ON jsonb_typeof(u.data->'designerAllCloseTime') = 'array'
  ) t
  WHERE uid IS NOT NULL AND uid <> ''
    AND off_at_text IS NOT NULL AND off_at_text <> ''
  ON CONFLICT (off_id) DO NOTHING;
END;
$$;
