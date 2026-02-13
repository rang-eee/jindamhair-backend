-- migrate_fs_appointments_to_tb_appointment.sql
-- Firestore fs_appointments -> tb_appointment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_to_tb_appointment()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_appointment RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_appointment (
    appointment_id,
    customer_uid,
    designer_uid,
    designer_shop_id,
    appointment_status_code,
    appointment_start_type_code,
    total_amount,
    appointment_amount,
    treatment_start_at,
    treatment_end_at,
    payment_method_code,
    appointment_content,
    cancel_reason_content,
    review_id,
    customer_name,
    customer_nickname,
    customer_contact,
    designer_name,
    designer_nickname,
    designer_contact,
    shop_name,
    shop_addr,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'userUid',
    data->>'designerUid',
    CASE
      WHEN COALESCE(data->>'designerUid','') <> '' AND COALESCE(data->>'storeId','') <> ''
        THEN (data->>'designerUid') || '_' || (data->>'storeId')
      ELSE NULL
    END,
    data->>'appointmentStatusType',
    data->>'beginMethodType',
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    NULL,
    fn_safe_timestamp(data->>'startAt'),
    fn_safe_timestamp(data->>'endAt'),
    data->>'paymentMethodType',
    data->>'hairTitle',
    data->>'cancelReason',
    data->>'reviewId',
    data->>'userName',
    data->>'userName',
    data->>'userPhoneNum',
    data->>'designerName',
    NULL,
    data->'designerModel'->>'phoneNum',
    data->>'storeName',
    data->'designerModel'->>'storeAddress',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_appointments
  ON CONFLICT (appointment_id) DO NOTHING;
END;
$$;
