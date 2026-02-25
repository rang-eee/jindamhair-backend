-- migrate_fs_dynamiclinks.sql
-- Firestore fs_dynamiclinks -> tb_deeplink 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_dynamiclinks_to_tb_deeplink()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_deeplink_deeplink_id restart with 1';
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
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_dynamiclinks
  ON CONFLICT (deeplink_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_deeplink');
END;
$$;
