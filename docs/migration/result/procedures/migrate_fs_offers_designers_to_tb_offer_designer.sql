-- migrate_fs_offers_designers_to_tb_offer_designer.sql
-- Firestore fs_offers__designers -> tb_offer_designer 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_offers_designers_to_tb_offer_designer()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_offer_designer RESTART IDENTITY CASCADE;

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
    nextval('seq_tb_offer_designer_offer_designer_id')::text AS offer_designer_id,
    COALESCE(o.offer_id, parent_doc_id) AS offer_id,
    data->>'status',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), now()),
    'migration',
    NULL,
    'migration',
    'N'
  FROM fs_offers__designers d
  LEFT JOIN jindamhair.tb_offer o
    ON o.migration_id = d.parent_doc_id
  ON CONFLICT (offer_designer_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_offer_designer');
END;
$$;
