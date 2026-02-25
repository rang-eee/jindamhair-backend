-- migrate_fs_reservations.sql
-- Firestore fs_reservations 업무 통합 프로시저 모음

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
    CASE
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.selectTime', 'selectTime', '시간선택', 'APST001') THEN 'selectTime'
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.selectPayment', 'selectPayment', '결제방법선택', 'APST002') THEN 'selectPayment'
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.disabled', 'disabled', '예약불가', 'APST003') THEN 'disabled'
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.requested', 'requested', '예약요청', 'APST004') THEN 'requested'
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.completed', 'completed', '예약완료', 'APST005') THEN 'completed'
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.getting', 'getting', '시술중', 'APST006') THEN 'getting'
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.finished', 'finished', '시술완료', 'APST007') THEN 'finished'
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.canceled', 'canceled', '예약취소', 'APST008') THEN 'canceled'
      WHEN TRIM(COALESCE(data->>'reservationStatus','')) IN ('AppointmentStatusType.reviewed', 'reviewed', '후기작성완료', 'APST009') THEN 'reviewed'
      ELSE data->>'reservationStatus'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'reservationType','')) IN ('BeginMethodType.byCustomer', 'byCustomer', '고객 예약', 'APSR001') THEN 'byCustomer'
      WHEN TRIM(COALESCE(data->>'reservationType','')) IN ('BeginMethodType.byDesigner', 'byDesigner', '디자이너 예약', 'APSR002') THEN 'byDesigner'
      WHEN TRIM(COALESCE(data->>'reservationType','')) IN ('BeginMethodType.changeByCustomer', 'changeByCustomer', '고객에 의한 변경', 'APSR003') THEN 'changeByCustomer'
      WHEN TRIM(COALESCE(data->>'reservationType','')) IN ('BeginMethodType.changeByDesigner', 'changeByDesigner', '디자이너에 의한 변경', 'APSR004') THEN 'changeByDesigner'
      WHEN TRIM(COALESCE(data->>'reservationType','')) IN ('BeginMethodType.reByCustomer', 'reByCustomer', '고객에 의한 재예약', 'APSR005') THEN 'reByCustomer'
      WHEN TRIM(COALESCE(data->>'reservationType','')) IN ('BeginMethodType.reByDesigner', 'reByDesigner', '디자이너에 의한 재예약', 'APSR006') THEN 'reByDesigner'
      WHEN TRIM(COALESCE(data->>'reservationType','')) IN ('BeginMethodType.offerByCustom', 'offerByCustom', '고객 제안을 통한 예약', 'APSR007') THEN 'offerByCustom'
      ELSE data->>'reservationType'
    END,
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    fn_safe_timestamp(data->>'startAt'),
    fn_safe_timestamp(data->>'endAt'),
    CASE
      WHEN TRIM(COALESCE(data->>'paymentMethod','')) IN ('PaymentMethodType.onSitePayment', 'onSitePayment', '현장결제', 'PMMT001') THEN 'onSitePayment'
      WHEN TRIM(COALESCE(data->>'paymentMethod','')) IN ('PaymentMethodType.inAppPayment', 'inAppPayment', '온라인결제', 'PMMT002') THEN 'inAppPayment'
      ELSE data->>'paymentMethod'
    END,
    data->>'hairTitle',
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

-- =====================================================
-- migrate_fs_reservations_menus_to_tb_appointment_treatment.sql
-- =====================================================
-- Firestore fs_reservations__menus -> tb_appointment_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_reservations_menus_to_tb_appointment_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  -- 예약/시술 통합 테이블: TRUNCATE는 상위 프로시저(appointments_menus)에서 1회만 수행

  INSERT INTO jindamhair.tb_appointment_treatment (
    appointment_treatment_id,
    designer_treatment_id,
    uid,
    treatment_name,
    basic_amount,
    discount_pt,
    discount_amount,
    hair_add_type_code,
    add_amount,
    total_amount,
    treatment_content,
    treatment_require_time,
    treatment_gender_type_code,
    discount_yn,
    add_yn,
    treatment_code_1,
    treatment_name_1,
    treatment_code_2,
    treatment_name_2,
    treatment_code_3,
    treatment_name_3,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_appointment_treatment_appointment_treatment_id')::text,
    dt.designer_treatment_id,
    COALESCE(u.uid, r.data->>'userUid'),
    m.data->>'title',
    CASE WHEN (m.data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'price')::numeric ELSE NULL END,
    CASE WHEN (m.data->>'percent') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'percent')::numeric ELSE NULL END,
    CASE WHEN (m.data->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'salePrice')::numeric ELSE NULL END,
    CASE
      WHEN TRIM(COALESCE(m.data->>'hairAddType','')) IN ('HairAddType.chinLine', 'chinLine', '턱선 아래', 'HATP002') THEN 'chinLine'
      WHEN TRIM(COALESCE(m.data->>'hairAddType','')) IN ('HairAddType.shoulderLine', 'shoulderLine', '어깨선 아래', 'HATP003') THEN 'shoulderLine'
      WHEN TRIM(COALESCE(m.data->>'hairAddType','')) IN ('HairAddType.chestLine', 'chestLine', '가슴선 아래', 'HATP004') THEN 'chestLine'
      WHEN TRIM(COALESCE(m.data->>'hairAddType','')) IN ('HairAddType.waistLine', 'waistLine', '허리선 아래', 'HATP005') THEN 'waistLine'
      ELSE m.data->>'hairAddType'
    END,
    CASE
      WHEN (m.data->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN
        (m.data->>'totalPrice')::numeric
        - CASE
            WHEN (m.data->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'salePrice')::numeric
            WHEN (m.data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'price')::numeric
            ELSE NULL
          END
      ELSE NULL
    END,
    CASE WHEN (m.data->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'totalPrice')::numeric ELSE NULL END,
    NULL,
    CASE WHEN (m.data->>'hairTime') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'hairTime')::numeric ELSE NULL END,
    CASE
      WHEN TRIM(COALESCE(m.data->>'hairGenderType','')) IN ('여성', 'female', 'GenderType.female', 'TGTP002') THEN 'female'
      WHEN TRIM(COALESCE(m.data->>'hairGenderType','')) IN ('남성', 'male', 'GenderType.male', 'TGTP003') THEN 'male'
      WHEN TRIM(COALESCE(m.data->>'hairGenderType','')) IN ('GenderType.all', 'all', '전체', 'TGTP001') THEN 'all'
      WHEN TRIM(COALESCE(m.data->>'hairGenderType','')) = '' THEN NULL
      ELSE 'all'
    END,
    CASE WHEN fn_safe_boolean(m.data->>'isSalePrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(m.data->>'isAddPrice') THEN 'Y' ELSE 'N' END,
    m.data->>'levelCode1',
    m.data->>'levelTitle1',
    m.data->>'levelCode2',
    m.data->>'levelTitle2',
    m.data->>'levelCode3',
    m.data->>'levelTitle3',
    COALESCE(m.data->>'id', m.doc_id),
    COALESCE(fn_safe_timestamp(m.data->>'createAt'), m.created_at, now()),
    'migration',
    m.updated_at,
    'migration',
    'N'
  FROM fs_reservations__menus m
  LEFT JOIN fs_reservations r
    ON r.doc_id = m.parent_doc_id
  LEFT JOIN LATERAL (
    SELECT dt.designer_treatment_id
    FROM jindamhair.tb_desinger_treatment dt
    WHERE dt.migration_id = COALESCE(m.data->>'menuId', m.data->>'id', m.doc_id)
       OR (
         dt.uid = r.data->>'designerUid'
         AND dt.treatment_name = m.data->>'title'
       )
    ORDER BY CASE
      WHEN dt.migration_id = COALESCE(m.data->>'menuId', m.data->>'id', m.doc_id) THEN 0
      ELSE 1
    END
    LIMIT 1
  ) dt ON true
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = r.data->>'userUid'
  ON CONFLICT (appointment_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_treatment');
END;
$$;
