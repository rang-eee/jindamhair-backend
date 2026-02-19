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
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_desinger_treatment_add_designer_treatment_add_id')::text AS designer_treatment_add_id,
    COALESCE(dt.designer_treatment_id, COALESCE((m.data::jsonb)->>'id', m.doc_id)) AS designer_treatment_id,
    (m.data::jsonb)->>'hairAddType',
    NULL,
    COALESCE((m.data::jsonb)->>'id', m.doc_id),
    COALESCE(fn_safe_timestamp((m.data::jsonb)->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus m
  LEFT JOIN jindamhair.tb_desinger_treatment dt
    ON dt.migration_id = COALESCE(m.data->>'id', m.doc_id)
  WHERE (m.data::jsonb)->>'hairAddType' IS NOT NULL AND (m.data::jsonb)->>'hairAddType' <> ''
  ON CONFLICT (designer_treatment_add_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_desinger_treatment_add');
END;
$$;
