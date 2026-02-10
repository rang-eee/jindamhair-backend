-- migrate_fs_stores_to_tb_shop.sql
-- Firestore fs_stores -> tb_shop 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_stores_to_tb_shop()
LANGUAGE plpgsql
AS $$
BEGIN
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'title',
    data->>'description',
    data->>'address',
    data->>'addressDetail',
    COALESCE(data->>'contactNumber', data->>'phoneNum'),
    data->>'gpsX',
    data->>'gpsY',
    data->>'postCode',
    'Y',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_stores
  ON CONFLICT (shop_id) DO NOTHING;
END;
$$;
