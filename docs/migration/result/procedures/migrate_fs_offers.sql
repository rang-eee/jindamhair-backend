-- migrate_fs_offers.sql
-- Firestore fs_offers -> tb_offer 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_offers_to_tb_offer()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_offer_offer_id restart with 1';
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_offer_designer_offer_designer_id restart with 1';
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_offer_treatment_offer_treatment_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_offer RESTART IDENTITY CASCADE;
  TRUNCATE TABLE jindamhair.tb_offer_designer RESTART IDENTITY CASCADE;
  TRUNCATE TABLE jindamhair.tb_offer_treatment RESTART IDENTITY CASCADE;

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
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_offer_offer_id')::text,
    CASE
      WHEN TRIM(COALESCE(data->>'offerStatusType','')) IN ('OfferStatusType.requested', 'requested', '고객 제안 요청', 'OFST001') THEN 'requested'
      WHEN TRIM(COALESCE(data->>'offerStatusType','')) IN ('OfferStatusType.accepted', 'accepted', '디자이너 수락 상태', 'OFST002') THEN 'accepted'
      WHEN TRIM(COALESCE(data->>'offerStatusType','')) IN ('OfferStatusType.completed', 'completed', '고객 예약 완료', 'OFST003') THEN 'completed'
      WHEN TRIM(COALESCE(data->>'offerStatusType','')) IN ('OfferStatusType.canceled', 'canceled', '고객 제안 취소', 'OFST004') THEN 'canceled'
      ELSE data->>'offerStatusType'
    END,
    COALESCE(u.uid, data->>'offerUid'),
    fn_safe_timestamp(data->>'offerAt'),
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    data->>'offerLocationAddress',
    NULLIF(TRIM(data->>'offerLocationDistance'), '')::numeric,
    NULLIF(TRIM(data->>'offerLocationLatitude'), '')::numeric,
    NULLIF(TRIM(data->>'offerLocationLongitude'), '')::numeric,
    data->>'offerMemo',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_offers o
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = o.data->>'offerUid'
  ON CONFLICT (offer_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_offer');

  INSERT INTO jindamhair.tb_offer_designer (
    offer_designer_id,
    offer_id,
    offer_agree_status_code,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_offer_designer_offer_designer_id')::text,
    o2.offer_id,
    CASE
      WHEN TRIM(COALESCE(di.value->>'status','')) IN ('CustomOfferRequestType.unknown', 'unknown', '미확인') THEN 'unknown'
      WHEN TRIM(COALESCE(di.value->>'status','')) IN ('waiting', '대기', 'CustomOfferRequestType.waiting', 'OAST001') THEN 'waiting'
      WHEN TRIM(COALESCE(di.value->>'status','')) IN ('accepted', 'selected', '수락', 'CustomOfferRequestType.accepted', 'OAST002') THEN 'accepted'
      WHEN TRIM(COALESCE(di.value->>'status','')) IN ('rejected', '거절', 'CustomOfferRequestType.rejected', 'OAST003') THEN 'rejected'
      WHEN TRIM(COALESCE(di.value->>'status','')) = '' THEN 'unknown'
      ELSE di.value->>'status'
    END,
    COALESCE(o.data->>'id', o.doc_id) || '_' || di.key,
    COALESCE(fn_safe_timestamp(o.data->>'createAt'), o.created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(o.data->>'updateAt'), o.updated_at),
    'migration',
    'N'
  FROM fs_offers o
  JOIN jindamhair.tb_offer o2
    ON o2.migration_id = COALESCE(o.data->>'id', o.doc_id)
  JOIN LATERAL jsonb_each(o.data->'designerInfos') di
    ON jsonb_typeof(o.data->'designerInfos') = 'object'
  ON CONFLICT (offer_designer_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_offer_designer');

  WITH base AS (
    SELECT doc_id, data
    FROM fs_offers
  ),
  lv1 AS (
    SELECT
      COALESCE(data->>'id', doc_id) AS offer_id,
      1::numeric AS treatment_level,
      code AS treatment_code
    FROM base
    JOIN LATERAL jsonb_array_elements_text(data->'levelCodes1') AS code
      ON jsonb_typeof(data->'levelCodes1') = 'array'
  ),
  lv2 AS (
    SELECT
      COALESCE(data->>'id', doc_id) AS offer_id,
      2::numeric AS treatment_level,
      code AS treatment_code
    FROM base
    JOIN LATERAL jsonb_array_elements_text(data->'levelCodes2') AS code
      ON jsonb_typeof(data->'levelCodes2') = 'array'
  ),
  lv3 AS (
    SELECT
      COALESCE(data->>'id', doc_id) AS offer_id,
      3::numeric AS treatment_level,
      code AS treatment_code
    FROM base
    JOIN LATERAL jsonb_array_elements_text(data->'levelCodes3') AS code
      ON jsonb_typeof(data->'levelCodes3') = 'array'
  ),
  all_lv AS (
    SELECT * FROM lv1
    UNION ALL
    SELECT * FROM lv2
    UNION ALL
    SELECT * FROM lv3
  )
  INSERT INTO jindamhair.tb_offer_treatment (
    offer_treatment_id,
    offer_id,
    treatment_level,
    treatment_code,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_offer_treatment_offer_treatment_id')::text AS offer_treatment_id,
    COALESCE(o3.offer_id, all_lv.offer_id),
    treatment_level,
    treatment_code,
    all_lv.offer_id || '_' || treatment_level::text || '_' || treatment_code,
    now(),
    'migration',
    NULL,
    'migration',
    'N'
  FROM all_lv
  LEFT JOIN jindamhair.tb_offer o3
    ON o3.migration_id = all_lv.offer_id
  WHERE COALESCE(all_lv.offer_id,'') <> '' AND COALESCE(treatment_code,'') <> ''
  ON CONFLICT (offer_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_offer_treatment');
END;
$$;
