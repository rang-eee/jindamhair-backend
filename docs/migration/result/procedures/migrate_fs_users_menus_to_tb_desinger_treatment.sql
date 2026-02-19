-- migrate_fs_users_menus_to_tb_desinger_treatment.sql
-- Firestore fs_users__menus -> tb_desinger_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_menus_to_tb_desinger_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_desinger_treatment RESTART IDENTITY CASCADE;

  -- 파일 URL 선적재 (중복 방지)
  INSERT INTO jindamhair.tb_file (
    file_id, sort_order, file_type_code, org_file_name, convert_file_name,
    file_path, file_size, migration_id, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
  )
  SELECT
    nextval('seq_tb_file_file_id')::text,
    1,
    'FLTP001',
    NULL,
    NULL,
    src.url,
    NULL,
    src.url,
    now(),
    'migration',
    NULL,
    NULL,
    'N',
    NULL,
    NULL
  FROM (
    SELECT DISTINCT (m.data::jsonb)->'hairImageUrl'->>0 AS url
    FROM fs_users__menus m
  ) src
  WHERE src.url IS NOT NULL AND src.url <> ''
    AND NOT EXISTS (
      SELECT 1 FROM jindamhair.tb_file f WHERE f.file_path = src.url
    );

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
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_desinger_treatment_designer_treatment_id')::text,
    COALESCE(u.uid, parent_doc_id),
    (m.data::jsonb)->>'title',
    CASE WHEN ((m.data::jsonb)->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'price')::numeric ELSE NULL END,
    CASE WHEN ((m.data::jsonb)->>'percent') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'percent')::numeric ELSE NULL END,
    CASE WHEN ((m.data::jsonb)->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'salePrice')::numeric ELSE NULL END,
    CASE WHEN ((m.data::jsonb)->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'totalPrice')::numeric ELSE NULL END,
    NULL,
    CASE WHEN ((m.data::jsonb)->>'hairTime') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'hairTime')::numeric ELSE NULL END,
    CASE
      WHEN jsonb_typeof((m.data::jsonb)->'hairImageUrl') = 'array' THEN tf.file_id
      ELSE NULL
    END,
    (m.data::jsonb)->>'hairGenderType',
    CASE WHEN fn_safe_boolean((m.data::jsonb)->>'isSalePrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean((m.data::jsonb)->>'isAddPrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean((m.data::jsonb)->>'isOpenMenu') THEN 'Y' ELSE 'N' END,
    CASE WHEN ((m.data::jsonb)->>'order') ~ '^[0-9]+$' THEN ((m.data::jsonb)->>'order')::numeric ELSE NULL END,
    (m.data::jsonb)->>'levelCode1',
    (m.data::jsonb)->>'levelTitle1',
    (m.data::jsonb)->>'levelCode2',
    (m.data::jsonb)->>'levelTitle2',
    (m.data::jsonb)->>'levelCode3',
    (m.data::jsonb)->>'levelTitle3',
    COALESCE((m.data::jsonb)->>'id', m.doc_id),
    COALESCE(fn_safe_timestamp((m.data::jsonb)->>'createAt'), m.created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus m
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = m.parent_doc_id
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = (m.data::jsonb)->'hairImageUrl'->>0 AND f.file_path <> ''
    ORDER BY f.file_id::bigint
    LIMIT 1
  ) tf ON true
  ON CONFLICT (designer_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_desinger_treatment');
END;
$$;
