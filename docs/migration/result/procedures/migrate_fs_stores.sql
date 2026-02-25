-- migrate_fs_stores.sql
-- Firestore fs_stores -> tb_shop 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_stores_to_tb_shop()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_shop_shop_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_shop RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_shop (
    shop_id,
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
      nextval('seq_tb_shop_shop_id')::text,
    data->>'title',
    data->>'description',
    data->>'address',
    data->>'addressDetail',
    COALESCE(data->>'contactNumber', data->>'phoneNum'),
    data->>'gpsX',
    data->>'gpsY',
    data->>'postCode',
    CASE
      WHEN data->>'storeStatusType' = 'StoreStatusType.active' THEN 'Y'
      WHEN data->>'storeStatusType' = 'StoreStatusType.unused' THEN 'N'
      WHEN data->>'storeStatusType' = 'StoreStatusType.delete' THEN 'N'
      ELSE 'Y'
    END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    CASE
      WHEN data->>'storeStatusType' = 'StoreStatusType.delete' THEN 'Y'
      ELSE 'N'
    END
  FROM fs_stores
  ON CONFLICT (shop_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_shop');
END;
$$;
