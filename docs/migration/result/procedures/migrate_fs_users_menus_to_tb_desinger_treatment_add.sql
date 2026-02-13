-- migrate_fs_users_menus_to_tb_desinger_treatment_add.sql
-- Firestore fs_users__menus -> tb_desinger_treatment_add 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_menus_to_tb_desinger_treatment_add()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_desinger_treatment_add RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_desinger_treatment_add (
    designer_treatment_add_id,
    designer_treatment_id,
    hair_add_type_code,
    add_amount,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id) || '_' || (data->>'hairAddType') AS designer_treatment_add_id,
    COALESCE(data->>'id', doc_id) AS designer_treatment_id,
    data->>'hairAddType',
    NULL,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus
  WHERE data->>'hairAddType' IS NOT NULL AND data->>'hairAddType' <> ''
  ON CONFLICT (designer_treatment_add_id) DO NOTHING;
END;
$$;
