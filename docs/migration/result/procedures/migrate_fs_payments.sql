-- migrate_fs_payments.sql
-- Firestore fs_payments -> tb_payment 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_payments_to_tb_payment()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_payment_payment_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_payment RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_payment (
    payment_id,
    payment_type_val,
    payment_key,
    order_id,
    payment_amount,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
      nextval('seq_tb_payment_payment_id')::text,
    data->>'paymentType',
    data->>'paymentKey',
    data->>'orderId',
    CASE
      WHEN (data->>'amount') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'amount')::numeric
      ELSE NULL
    END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_payments
  ON CONFLICT (payment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_payment');
END;
$$;
