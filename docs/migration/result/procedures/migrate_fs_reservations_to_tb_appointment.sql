-- migrate_fs_reservations_to_tb_appointment.sql
-- Firestore fs_reservations -> tb_appointment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_reservations_to_tb_appointment()
LANGUAGE plpgsql
AS $$
BEGIN
  -- 예약/시술 통합 테이블: TRUNCATE는 상위 프로시저(appointments)에서 1회만 수행

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
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_appointment_appointment_id')::text,
    COALESCE(cu.uid, data->>'userUid'),
    COALESCE(du.uid, data->>'designerUid'),
    ds.designer_shop_id,
    LEFT(data->>'reservationStatus', 200),
    LEFT(data->>'reservationType', 200),
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    fn_safe_timestamp(data->>'startAt'),
    fn_safe_timestamp(data->>'endAt'),
    LEFT(data->>'paymentMethod', 200),
    data->>'hairTitle',
    NULL,
    NULL,
    data->>'userName',
    data->>'userName',
    data->>'userPhoneNum',
    COALESCE(data->>'designerName', data->'designerModel'->>'name'),
    data->'designerModel'->>'nickname',
    data->'designerModel'->>'phoneNum',
    COALESCE(data->>'storeName', data->'designerModel'->>'storeName'),
    COALESCE(data->>'storeAddress', data->'designerModel'->>'storeAddress'),
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_reservations r
  LEFT JOIN jindamhair.tb_user cu
    ON cu.migration_id = r.data->>'userUid'
  LEFT JOIN jindamhair.tb_user du
    ON du.migration_id = r.data->>'designerUid'
  LEFT JOIN jindamhair.tb_designer_shop ds
    ON ds.migration_id = COALESCE(
      r.data->>'designerShopId',
      r.data->>'designerShopID',
      CASE
        WHEN COALESCE(r.data->>'designerUid','') <> ''
          AND COALESCE(r.data->>'storeId', r.data->'designerModel'->>'storeId','') <> ''
          THEN (r.data->>'designerUid') || '_' || COALESCE(r.data->>'storeId', r.data->'designerModel'->>'storeId')
        ELSE NULL
      END
    )
  ON CONFLICT (appointment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment');
END;
$$;
