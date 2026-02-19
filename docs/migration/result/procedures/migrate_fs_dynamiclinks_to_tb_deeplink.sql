-- migrate_fs_dynamiclinks_to_tb_deeplink.sql
-- Firestore fs_dynamiclinks -> tb_deeplink 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_dynamiclinks_to_tb_deeplink()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_deeplink RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_deeplink (
    deeplink_id,
    deeplink_key,
    deeplink_email,
    deeplink_url,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
      nextval('seq_tb_deeplink_deeplink_id')::text,
    data->>'linkKey',
    data->>'email',
    data->>'link',
    COALESCE(data->>'id', doc_id),
    COALESCE((data->>'createAt')::timestamp, created_at, now()),
    'migration',
    COALESCE((data->>'updateAt')::timestamp, updated_at),
    'migration',
    'N'
  FROM fs_dynamiclinks
  ON CONFLICT (deeplink_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_deeplink');
END;
$$;
