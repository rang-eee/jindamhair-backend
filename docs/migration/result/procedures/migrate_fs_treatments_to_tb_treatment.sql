-- migrate_fs_treatments_to_tb_treatment.sql
-- Firestore fs_treatments -> tb_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_treatments_to_tb_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_treatment RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_treatment (
    treatment_id,
    treatment_code,
    treatment_name,
    treatment_level,
    sort_order,
    offer_minimum_amount,
    use_yn,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'code',
    data->>'title',
    NULLIF(data->>'level', '')::numeric,
    NULLIF(data->>'sort', '')::numeric,
    NULLIF(data->>'offerMinPrice', '')::numeric,
    CASE WHEN fn_safe_boolean(data->>'useYn') THEN 'Y' ELSE 'N' END,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_treatments
  ON CONFLICT (treatment_id) DO NOTHING;
END;
$$;
