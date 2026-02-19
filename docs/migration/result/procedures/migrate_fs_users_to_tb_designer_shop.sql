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
      b.doc_id AS owner_doc_id,
      COALESCE(b.data->>'uid', b.data->>'id', b.doc_id) AS uid,
      b.data->>'storeId' AS shop_id,
      b.data->>'storeName' AS shop_name,
      b.data->>'storeAddress' AS shop_addr,
      NULL::text AS shop_addr_detail,
      b.data->>'storePhoneNum' AS shop_contact,
      NULL::text AS position_lngt,
      NULL::text AS position_latt,
      NULL::text AS zipcode,
      'Y'::bpchar AS representative_yn,
      NULL::text AS shop_regist_type_code,
      'Y'::bpchar AS use_yn,
      b.created_at,
      b.updated_at
    FROM base b
    WHERE COALESCE(b.data->>'storeId','') <> ''
  ),
  extra_shops AS (
    SELECT
      b.doc_id AS owner_doc_id,
      COALESCE(b.data->>'uid', b.data->>'id', b.doc_id) AS uid,
      COALESCE(uss.data->>'id', uss.data->>'storeId', uss.doc_id) AS shop_id,
      COALESCE(uss.data->>'title', uss.data->>'name', uss.data->>'storeName') AS shop_name,
      COALESCE(uss.data->>'address', uss.data->>'storeAddress') AS shop_addr,
      uss.data->>'addressDetail' AS shop_addr_detail,
      COALESCE(uss.data->>'contactNumber', uss.data->>'phoneNum', uss.data->>'storePhoneNum') AS shop_contact,
      uss.data->>'gpsX' AS position_lngt,
      uss.data->>'gpsY' AS position_latt,
      uss.data->>'postCode' AS zipcode,
      CASE WHEN fn_safe_boolean(uss.data->>'isRepresentative') THEN 'Y' ELSE 'N' END AS representative_yn,
      uss.data->>'storeAddType' AS shop_regist_type_code,
      'Y'::bpchar AS use_yn,
      COALESCE(uss.created_at, b.created_at) AS created_at,
      COALESCE(uss.updated_at, b.updated_at) AS updated_at
    FROM base b
    JOIN fs_users__stores uss
      ON uss.parent_doc_id = b.doc_id
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
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_designer_shop_designer_shop_id')::text AS designer_shop_id,
    COALESCE(u.uid, combined.uid),
    s.shop_id,
    CASE
      WHEN s.shop_id IS NULL THEN 'StoreAddType.add'
      ELSE 'StoreAddType.basic'
    END,
    representative_yn,
    COALESCE(s.shop_name, uss.data->>'title', combined.shop_name),
    NULL,
    COALESCE(s.shop_addr, uss.data->>'address', combined.shop_addr),
    COALESCE(s.shop_addr_detail, uss.data->>'addressDetail', combined.shop_addr_detail),
    COALESCE(s.shop_contact, uss.data->>'contactNumber', uss.data->>'phoneNum', combined.shop_contact),
    COALESCE(s.position_lngt, uss.data->>'gpsX', combined.position_lngt),
    COALESCE(s.position_latt, uss.data->>'gpsY', combined.position_latt),
    COALESCE(s.zipcode, uss.data->>'postCode', combined.zipcode),
    combined.use_yn,
    combined.uid || '_' || combined.shop_id,
    COALESCE(combined.created_at, now()),
    'migration',
    combined.updated_at,
    'migration',
    'N'
  FROM combined
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = combined.uid
  LEFT JOIN jindamhair.tb_shop s
    ON s.migration_id = combined.shop_id
  LEFT JOIN fs_users__stores uss
    ON uss.parent_doc_id = combined.owner_doc_id
   AND COALESCE(uss.data->>'id', uss.data->>'storeId', uss.doc_id) = combined.shop_id
  WHERE COALESCE(combined.uid,'') <> ''
    AND COALESCE(combined.shop_id,'') <> ''
  ON CONFLICT (designer_shop_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_designer_shop');
END;
$$;
