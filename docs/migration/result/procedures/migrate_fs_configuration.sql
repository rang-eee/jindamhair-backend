-- migrate_fs_configuration.sql
-- Firestore fs_configuration -> tb_configuration 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_configuration_to_tb_configuration()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_configuration RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_configuration (
    aos_last_ver,
    aos_permission_minimum_build_number,
    ios_last_ver,
    ios_permission_minimum_build_number,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn,
    delete_id,
    delete_at
  )
  SELECT
    COALESCE(data->>'aosLastestVersion', data->>'lastest_version', data->>'lastestVersion'),
    COALESCE(data->>'aosAllowMinmumBuildNumber', data->>'allow_minmum_build_number', data->>'allowMinmumBuildNumber'),
    COALESCE(data->>'iosLastestVersion', data->>'lastest_version', data->>'lastestVersion'),
    COALESCE(data->>'iosAllowMinmumBuildNumber', data->>'allow_minmum_build_number', data->>'allowMinmumBuildNumber'),
    COALESCE(data->>'id', doc_id),
    now(),
    'migration',
    NULL,
    'migration',
    'N',
    NULL,
    NULL
  FROM fs_configuration
  WHERE NOT EXISTS (SELECT 1 FROM jindamhair.tb_configuration)
  ORDER BY created_at DESC NULLS LAST
  LIMIT 1;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_configuration');
END;
$$;
