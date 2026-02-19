-- migrate_fs_treatmentclassfications_to_tb_treatment_class.sql
-- Firestore fs_treatmentclassfications -> tb_treatment_class 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_treatmentclassfications_to_tb_treatment_class()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_treatment_class RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_treatment_class (
    treatment_class_id,
    treatment_code,
    treatment_name,
    treatment_level,
    treatment_code_1,
    treatment_name_1,
    treatment_code_2,
    treatment_name_2,
    treatment_code_3,
    treatment_name_3,
    sort_order,
    use_yn,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_treatment_treatment_class_id')::text,
    data->>'code',
    data->>'title',
    NULLIF(data->>'level', '')::numeric,
    data->>'levelCode1',
    data->>'levelTitle1',
    data->>'levelCode2',
    data->>'levelTitle2',
    data->>'levelCode3',
    data->>'levelTitle3',
    NULLIF(data->>'sort', '')::numeric,
    CASE WHEN fn_safe_boolean(data->>'useYn') THEN 'Y' ELSE 'N' END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_treatmentclassfications
  ON CONFLICT (treatment_class_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_treatment_class');
END;
$$;
