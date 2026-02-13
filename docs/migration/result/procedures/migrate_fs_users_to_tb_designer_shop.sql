-- migrate_fs_users_to_tb_designer_shop.sql
-- Firestore fs_users -> tb_designer_shop 이관 프로시저 (users.stores 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_shop()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_designer_shop RESTART IDENTITY CASCADE;

  WITH base AS (
    SELECT doc_id, data, created_at, updated_at
    FROM fs_users
  ),
  primary_shop AS (
    SELECT
      COALESCE(data->>'uid', data->>'id', doc_id) AS uid,
      data->>'storeId' AS shop_id,
      data->>'storeName' AS shop_name,
      data->>'storeAddress' AS shop_addr,
      NULL::text AS shop_addr_detail,
      data->>'storePhoneNum' AS shop_contact,
      NULL::text AS position_lngt,
      NULL::text AS position_latt,
      NULL::text AS zipcode,
      'Y'::bpchar AS representative_yn,
      NULL::text AS shop_regist_type_code,
      'Y'::bpchar AS use_yn,
      created_at,
      updated_at
    FROM base
    WHERE COALESCE(data->>'storeId','') <> ''
  ),
  extra_shops AS (
    SELECT
      COALESCE(b.data->>'uid', b.data->>'id', b.doc_id) AS uid,
      COALESCE(s.value->>'id', s.value->>'storeId') AS shop_id,
      COALESCE(s.value->>'title', s.value->>'name', s.value->>'storeName') AS shop_name,
      COALESCE(s.value->>'address', s.value->>'storeAddress') AS shop_addr,
      s.value->>'addressDetail' AS shop_addr_detail,
      COALESCE(s.value->>'contactNumber', s.value->>'phoneNum', s.value->>'storePhoneNum') AS shop_contact,
      s.value->>'gpsX' AS position_lngt,
      s.value->>'gpsY' AS position_latt,
      s.value->>'postCode' AS zipcode,
      CASE WHEN fn_safe_boolean(s.value->>'isRepresentative') THEN 'Y' ELSE 'N' END AS representative_yn,
      s.value->>'storeAddType' AS shop_regist_type_code,
      'Y'::bpchar AS use_yn,
      b.created_at,
      b.updated_at
    FROM base b
    JOIN LATERAL jsonb_array_elements(b.data->'stores') AS s(value)
      ON jsonb_typeof(b.data->'stores') = 'array'
  ),
  combined AS (
    SELECT * FROM primary_shop
    UNION ALL
    SELECT * FROM extra_shops
  )
  INSERT INTO jindamhair.tb_designer_shop (
    designer_shop_id,
    uid,
    shop_id,
    shop_regist_type_code,
    representative_yn,
    shop_name,
    shop_description,
    shop_addr,
    shop_addr_detail,
    shop_contact,
    position_lngt,
    position_latt,
    zipcode,
    use_yn,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    uid || '_' || shop_id AS designer_shop_id,
    uid,
    shop_id,
    shop_regist_type_code,
    representative_yn,
    shop_name,
    NULL,
    shop_addr,
    shop_addr_detail,
    shop_contact,
    position_lngt,
    position_latt,
    zipcode,
    use_yn,
    COALESCE(created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM combined
  WHERE COALESCE(uid,'') <> ''
    AND COALESCE(shop_id,'') <> ''
  ON CONFLICT (designer_shop_id) DO NOTHING;
END;
$$;
