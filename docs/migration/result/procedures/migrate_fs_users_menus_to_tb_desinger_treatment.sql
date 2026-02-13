-- migrate_fs_users_menus_to_tb_desinger_treatment.sql
-- Firestore fs_users__menus -> tb_desinger_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_menus_to_tb_desinger_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_desinger_treatment RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_desinger_treatment (
    designer_treatment_id,
    uid,
    treatment_name,
    basic_amount,
    discount_pt,
    discount_amount,
    total_amount,
    treatment_content,
    treatment_require_time,
    treatment_photo_file_id,
    treatment_gender_type_code,
    discount_yn,
    add_yn,
    open_yn,
    sort_order,
    treatment_code_1,
    treatment_name_1,
    treatment_code_2,
    treatment_name_2,
    treatment_code_3,
    treatment_name_3,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    parent_doc_id,
    data->>'title',
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    CASE WHEN (data->>'percent') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'percent')::numeric ELSE NULL END,
    CASE WHEN (data->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'salePrice')::numeric ELSE NULL END,
    CASE WHEN (data->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'totalPrice')::numeric ELSE NULL END,
    NULL,
    CASE WHEN (data->>'hairTime') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'hairTime')::numeric ELSE NULL END,
    CASE
      WHEN jsonb_typeof(data->'hairImageUrl') = 'array' THEN COALESCE(tf.file_id, tfi.file_id)
      ELSE NULL
    END,
    data->>'hairGenderType',
    CASE WHEN fn_safe_boolean(data->>'isSalePrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(data->>'isAddPrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(data->>'isOpenMenu') THEN 'Y' ELSE 'N' END,
    CASE WHEN (data->>'order') ~ '^[0-9]+$' THEN (data->>'order')::numeric ELSE NULL END,
    data->>'levelCode1',
    data->>'levelTitle1',
    data->>'levelCode2',
    data->>'levelTitle2',
    data->>'levelCode3',
    data->>'levelTitle3',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus m
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = m.data->'hairImageUrl'->>0 AND f.file_path <> ''
    LIMIT 1
  ) tf ON true
  LEFT JOIN LATERAL (
    INSERT INTO jindamhair.tb_file (
      file_id, sort_order, file_type_code, org_file_name, convert_file_name,
      file_path, file_size, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
    )
    SELECT nextval('seq_tb_file_file_id')::text, 1, 'FLTP001', NULL, NULL,
      m.data->'hairImageUrl'->>0, NULL, now(), 'migration', NULL, NULL, 'N', NULL, NULL
    WHERE (m.data->'hairImageUrl'->>0) IS NOT NULL AND (m.data->'hairImageUrl'->>0) <> '' AND tf.file_id IS NULL
    RETURNING file_id
  ) tfi ON true
  ON CONFLICT (designer_treatment_id) DO NOTHING;
END;
$$;
