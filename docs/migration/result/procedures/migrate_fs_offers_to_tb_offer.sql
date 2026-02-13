-- migrate_fs_offers_to_tb_offer.sql
-- Firestore fs_offers -> tb_offer 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_offers_to_tb_offer()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_offer RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_offer (
    offer_id,
    offer_status_code,
    offer_uid,
    offer_at,
    offer_amount,
    offer_position_addr,
    offer_position_distance,
    offer_position_latt,
    offer_position_lngt,
    offer_memo_content,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'offerStatusType',
    data->>'offerUid',
    fn_safe_timestamp(data->>'offerAt'),
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    data->>'offerLocationAddress',
    CASE WHEN (data->>'offerLocationDistance') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationDistance')::numeric ELSE NULL END,
    CASE WHEN (data->>'offerLocationLatitude') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationLatitude')::numeric ELSE NULL END,
    CASE WHEN (data->>'offerLocationLongitude') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationLongitude')::numeric ELSE NULL END,
    data->>'offerMemo',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_offers
  ON CONFLICT (offer_id) DO NOTHING;
END;
$$;
