-- migrate_fs_appointments.sql
-- Firestore fs_appointments 업무 통합 프로시저 모음

-- migrate_fs_appointments_to_tb_appointment.sql
-- Firestore fs_appointments -> tb_appointment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_to_tb_appointment()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_appointment_appointment_id restart with 1';
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
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.selectTime', 'selectTime', '시간선택', 'APST001') THEN 'selectTime'
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.selectPayment', 'selectPayment', '결제방법선택', 'APST002') THEN 'selectPayment'
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.disabled', 'disabled', '예약불가', 'APST003') THEN 'disabled'
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.requested', 'requested', '예약요청', 'APST004') THEN 'requested'
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.completed', 'completed', '예약완료', 'APST005') THEN 'completed'
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.getting', 'getting', '시술중', 'APST006') THEN 'getting'
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.finished', 'finished', '시술완료', 'APST007') THEN 'finished'
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.canceled', 'canceled', '예약취소', 'APST008') THEN 'canceled'
      WHEN TRIM(COALESCE(data->>'appointmentStatusType','')) IN ('AppointmentStatusType.reviewed', 'reviewed', '후기작성완료', 'APST009') THEN 'reviewed'
      ELSE data->>'appointmentStatusType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'beginMethodType','')) IN ('BeginMethodType.byCustomer', 'byCustomer', '고객 예약', 'APSR001') THEN 'byCustomer'
      WHEN TRIM(COALESCE(data->>'beginMethodType','')) IN ('BeginMethodType.byDesigner', 'byDesigner', '디자이너 예약', 'APSR002') THEN 'byDesigner'
      WHEN TRIM(COALESCE(data->>'beginMethodType','')) IN ('BeginMethodType.changeByCustomer', 'changeByCustomer', '고객에 의한 변경', 'APSR003') THEN 'changeByCustomer'
      WHEN TRIM(COALESCE(data->>'beginMethodType','')) IN ('BeginMethodType.changeByDesigner', 'changeByDesigner', '디자이너에 의한 변경', 'APSR004') THEN 'changeByDesigner'
      WHEN TRIM(COALESCE(data->>'beginMethodType','')) IN ('BeginMethodType.reByCustomer', 'reByCustomer', '고객에 의한 재예약', 'APSR005') THEN 'reByCustomer'
      WHEN TRIM(COALESCE(data->>'beginMethodType','')) IN ('BeginMethodType.reByDesigner', 'reByDesigner', '디자이너에 의한 재예약', 'APSR006') THEN 'reByDesigner'
      WHEN TRIM(COALESCE(data->>'beginMethodType','')) IN ('BeginMethodType.offerByCustom', 'offerByCustom', '고객 제안을 통한 예약', 'APSR007') THEN 'offerByCustom'
      ELSE data->>'beginMethodType'
    END,
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    fn_safe_timestamp(data->>'startAt'),
    fn_safe_timestamp(data->>'endAt'),
    CASE
      WHEN TRIM(COALESCE(data->>'paymentMethodType','')) IN ('PaymentMethodType.onSitePayment', 'onSitePayment', '현장결제', 'PMMT001') THEN 'onSitePayment'
      WHEN TRIM(COALESCE(data->>'paymentMethodType','')) IN ('PaymentMethodType.inAppPayment', 'inAppPayment', '온라인결제', 'PMMT002') THEN 'inAppPayment'
      ELSE data->>'paymentMethodType'
    END,
    data->>'hairTitle',
    data->>'cancelReason',
    data->>'userName',
    data->>'userName',
    data->>'userPhoneNum',
    COALESCE(data->>'designerName', du.user_name),
    COALESCE(data->'designerModel'->>'nickname', du.user_nickname),
    COALESCE(NULLIF(TRIM(data->'designerModel'->>'phoneNum'), ''), NULLIF(TRIM(du.user_contact), '')),
    COALESCE(data->>'storeName', ds.shop_name),
    COALESCE(data->'designerModel'->>'storeAddress', ds.shop_addr),
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_appointments a
  LEFT JOIN jindamhair.tb_user cu
    ON cu.migration_id = a.data->>'userUid'
  LEFT JOIN jindamhair.tb_user du
    ON du.migration_id = a.data->>'designerUid'
  LEFT JOIN jindamhair.tb_designer_shop ds
    ON ds.migration_id = COALESCE(
      a.data->>'designerShopId',
      a.data->>'designerShopID',
      CASE
        WHEN COALESCE(a.data->>'designerUid','') <> '' AND COALESCE(a.data->>'storeId','') <> ''
          THEN (a.data->>'designerUid') || '_' || (a.data->>'storeId')
        ELSE NULL
      END
    )
  ON CONFLICT (appointment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment');
END;
$$;

-- =====================================================
-- migrate_fs_appointments_menus_to_tb_appointment_treatment.sql
-- =====================================================
-- Firestore fs_appointments__menus -> tb_appointment_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_menus_to_tb_appointment_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_appointment_treatment_appointment_treatment_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_appointment_treatment RESTART IDENTITY CASCADE;

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
    COALESCE(u.uid, a.data->>'userUid'),
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
  FROM fs_appointments__menus m
  LEFT JOIN fs_appointments a
    ON a.doc_id = m.parent_doc_id
  LEFT JOIN LATERAL (
    SELECT dt.designer_treatment_id
    FROM jindamhair.tb_desinger_treatment dt
    WHERE dt.migration_id = COALESCE(m.data->>'menuId', m.data->>'id', m.doc_id)
       OR (
         dt.uid = a.data->>'designerUid'
         AND dt.treatment_name = m.data->>'title'
       )
    ORDER BY CASE
      WHEN dt.migration_id = COALESCE(m.data->>'menuId', m.data->>'id', m.doc_id) THEN 0
      ELSE 1
    END
    LIMIT 1
  ) dt ON true
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = a.data->>'userUid'
  ON CONFLICT (appointment_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_treatment');
END;
$$;

-- =====================================================
-- migrate_fs_appointments_sign_to_tb_appointment_sign.sql
-- =====================================================
-- Firestore fs_appointments__sign -> tb_appointment_sign 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_sign_to_tb_appointment_sign()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_appointment_sign_appointment_sign_id restart with 1';
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_appointment_sign_line_appointment_sign_line_id restart with 1';
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_appointment_sign_point_appointment_sign_point_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_appointment_sign RESTART IDENTITY CASCADE;
  TRUNCATE TABLE jindamhair.tb_appointment_sign_line RESTART IDENTITY CASCADE;
  TRUNCATE TABLE jindamhair.tb_appointment_sign_point RESTART IDENTITY CASCADE;

  WITH base AS (
    SELECT
      s.doc_id,
      s.parent_doc_id,
      s.data,
      s.created_at,
      s.updated_at,
      ROW_NUMBER() OVER (
        PARTITION BY s.parent_doc_id
        ORDER BY COALESCE(fn_safe_timestamp(s.data->>'createAt'), s.created_at) DESC, s.doc_id
      ) AS rn
    FROM fs_appointments__sign s
  ),
  sign_base AS (
    SELECT *
    FROM base
    WHERE rn = 1
  ),
  ins_sign AS (
    INSERT INTO jindamhair.tb_appointment_sign (
      appointment_sign_id,
      migration_id,
      create_at,
      create_id,
      update_at,
      update_id,
      delete_yn
    )
    SELECT
      nextval('seq_tb_appointment_sign_appointment_sign_id')::text,
      parent_doc_id,
      COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
      'migration',
      updated_at,
      'migration',
      'N'
    FROM sign_base
    RETURNING appointment_sign_id, migration_id
  ),
  ins_line AS (
    INSERT INTO jindamhair.tb_appointment_sign_line (
      appointment_sign_line_id,
      appointment_sign_id,
      sort_order,
      migration_id,
      create_at,
      create_id,
      update_at,
      update_id,
      delete_yn
    )
    SELECT
      nextval('seq_tb_appointment_sign_line_appointment_sign_line_id')::text,
      ins_sign.appointment_sign_id,
      CASE
        WHEN (base.data->>'sortOrder') ~ '^[0-9]+$' THEN (base.data->>'sortOrder')::numeric
        WHEN (base.data->>'order') ~ '^[0-9]+$' THEN (base.data->>'order')::numeric
        ELSE 0
      END,
      base.doc_id,
      COALESCE(fn_safe_timestamp(base.data->>'createAt'), base.created_at, now()),
      'migration',
      base.updated_at,
      'migration',
      'N'
    FROM base
    JOIN ins_sign
      ON ins_sign.migration_id = base.parent_doc_id
    RETURNING appointment_sign_line_id, migration_id
  )
  INSERT INTO jindamhair.tb_appointment_sign_point (
    appointment_sign_point_id,
    appointment_sign_line_id,
    sign_offset_x,
    sign_offset_y,
    sign_size,
    sign_color,
    sort_order,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_appointment_sign_point_appointment_sign_point_id')::text,
    ins_line.appointment_sign_line_id,
    p.value->>'offsetX',
    p.value->>'offsetY',
    p.value->>'size',
    p.value->>'color',
    p.ordinality::numeric,
    base.doc_id || '_' || p.ordinality::text,
    COALESCE(fn_safe_timestamp(base.data->>'createAt'), base.created_at, now()),
    'migration',
    base.updated_at,
    'migration',
    'N'
  FROM base
  JOIN ins_line
    ON ins_line.migration_id = base.doc_id
  JOIN LATERAL jsonb_array_elements(base.data->'data') WITH ORDINALITY AS p(value, ordinality)
    ON jsonb_typeof(base.data->'data') = 'array'
  ON CONFLICT (appointment_sign_point_id) DO NOTHING;

  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_sign');
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_sign_line');
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_sign_point');
END;
$$;

-- =====================================================
-- migrate_fs_appointments_sign_to_tb_appointment_sign_line.sql
-- =====================================================
-- Firestore fs_appointments__sign -> tb_appointment_sign_line 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_sign_to_tb_appointment_sign_line()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_appointment_sign_line_appointment_sign_line_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_appointment_sign_line RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_appointment_sign_line (
    appointment_sign_line_id,
    appointment_sign_id,
    sort_order,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_appointment_sign_line_appointment_sign_line_id')::text,
    sgn.appointment_sign_id,
    CASE
      WHEN (s.data->>'sortOrder') ~ '^[0-9]+$' THEN (s.data->>'sortOrder')::numeric
      WHEN (s.data->>'order') ~ '^[0-9]+$' THEN (s.data->>'order')::numeric
      ELSE 0
    END,
    COALESCE(s.data->>'id', s.doc_id),
    COALESCE(fn_safe_timestamp(s.data->>'createAt'), s.created_at, now()),
    'migration',
    s.updated_at,
    'migration',
    'N'
  FROM fs_appointments__sign s
  LEFT JOIN jindamhair.tb_appointment_sign sgn
    ON sgn.migration_id = COALESCE(s.data->>'id', s.doc_id)
  ON CONFLICT (appointment_sign_line_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_sign_line');
END;
$$;

-- =====================================================
-- migrate_fs_appointments_sign_to_tb_appointment_sign_point.sql
-- =====================================================
-- Firestore fs_appointments__sign -> tb_appointment_sign_point 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_sign_to_tb_appointment_sign_point()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_appointment_sign_point_appointment_sign_point_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_appointment_sign_point RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_appointment_sign_point (
    appointment_sign_point_id,
    appointment_sign_line_id,
    sign_offset_x,
    sign_offset_y,
    sign_size,
    sign_color,
    sort_order,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_appointment_sign_point_appointment_sign_point_id')::text,
    sl.appointment_sign_line_id,
    p.value->>'offsetX',
    p.value->>'offsetY',
    p.value->>'size',
    p.value->>'color',
    p.ordinality::numeric,
    COALESCE(s.data->>'id', s.doc_id) || '_' || p.ordinality::text,
    COALESCE(fn_safe_timestamp(s.data->>'createAt'), s.created_at, now()),
    'migration',
    s.updated_at,
    'migration',
    'N'
  FROM fs_appointments__sign s
  LEFT JOIN jindamhair.tb_appointment_sign_line sl
    ON sl.migration_id = COALESCE(s.data->>'id', s.doc_id)
  JOIN LATERAL jsonb_array_elements(s.data->'data') WITH ORDINALITY AS p(value, ordinality)
    ON jsonb_typeof(s.data->'data') = 'array'
  ON CONFLICT (appointment_sign_point_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_sign_point');
END;
$$;
