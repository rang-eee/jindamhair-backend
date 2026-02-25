-- migrate_fs_reviews.sql
-- Firestore fs_reviews -> tb_review 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_reviews_to_tb_review()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_review_review_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_review RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_review (
    review_id,
    appointment_id,
    review_type_code_arr,
    review_content,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_review_review_id')::text,
    COALESCE(a.appointment_id, data->>'appointmentId'),
    CASE
      WHEN jsonb_typeof(data->'reviewType') = 'array' THEN
        ARRAY(
          SELECT CASE
            WHEN TRIM(COALESCE(elem,'')) IN ('ReviewType.friendlyService', 'friendlyService', '친절한 서비스', 'RVTP001') THEN 'friendlyService'
            WHEN TRIM(COALESCE(elem,'')) IN ('ReviewType.professionalSkill', 'professionalSkill', '전문적인 시술 실력', 'RVTP002') THEN 'professionalSkill'
            WHEN TRIM(COALESCE(elem,'')) IN ('ReviewType.greatStyling', 'greatStyling', '스타일 완성도/만족', 'RVTP003') THEN 'greatStyling'
            WHEN TRIM(COALESCE(elem,'')) IN ('ReviewType.goodCommunication', 'goodCommunication', '상담/소통 만족', 'RVTP004') THEN 'goodCommunication'
            ELSE elem
          END
          FROM jsonb_array_elements_text(data->'reviewType') AS elem
        )
      ELSE NULL
    END,
    data->>'reviewContent',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_reviews r
  LEFT JOIN jindamhair.tb_appointment a
    ON a.migration_id = r.data->>'appointmentId'
  ON CONFLICT (review_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_review');
  PERFORM jindamhair.normalize_blank_array_to_null('jindamhair', 'tb_review');
END;
$$;


-- migrate_fs_reviews.sql
-- Firestore fs_reviews -> tb_review 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_reviews_to_tb_review()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_review_review_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_review RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_review (
    review_id,
    appointment_id,
    review_type_code_arr,
    review_content,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_review_review_id')::text,
    COALESCE(a.appointment_id, data->>'appointmentId'),
    CASE
      WHEN jsonb_typeof(data->'reviewType') = 'array' THEN
        ARRAY(
          SELECT CASE
            WHEN TRIM(COALESCE(elem,'')) IN ('ReviewType.friendlyService', 'friendlyService', '친절한 서비스', 'RVTP001') THEN 'friendlyService'
            WHEN TRIM(COALESCE(elem,'')) IN ('ReviewType.professionalSkill', 'professionalSkill', '전문적인 시술 실력', 'RVTP002') THEN 'professionalSkill'
            WHEN TRIM(COALESCE(elem,'')) IN ('ReviewType.greatStyling', 'greatStyling', '스타일 완성도/만족', 'RVTP003') THEN 'greatStyling'
            WHEN TRIM(COALESCE(elem,'')) IN ('ReviewType.goodCommunication', 'goodCommunication', '상담/소통 만족', 'RVTP004') THEN 'goodCommunication'
            ELSE elem
          END
          FROM jsonb_array_elements_text(data->'reviewType') AS elem
        )
      ELSE NULL
    END,
    data->>'reviewContent',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_reviews r
  LEFT JOIN jindamhair.tb_appointment a
    ON a.migration_id = r.data->>'appointmentId'
  ON CONFLICT (review_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_review');
  PERFORM jindamhair.normalize_blank_array_to_null('jindamhair', 'tb_review');
END;
$$;


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


-- migrate_fs_pushes.sql
-- Firestore fs_pushes -> tb_user_push 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_pushes_to_tb_user_push()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_user_push_user_push_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_user_push RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_user_push (
    user_push_id,
    sender_uid,
    receiver_uid,
    push_title,
    push_content,
    send_at,
    send_yn,
    send_complete_at,
    push_type_code,
    push_link_val,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_user_push_user_push_id')::text,
    CASE
      WHEN TRIM(COALESCE(data->>'pushType','')) IN ('PushType.chat', 'chat', '채팅', 'PSTP001') THEN 'chat'
      WHEN TRIM(COALESCE(data->>'pushType','')) IN ('PushType.appointment', 'appointment', '예약', 'PSTP002') THEN 'appointment'
      WHEN TRIM(COALESCE(data->>'pushType','')) IN ('PushType.recommand', 'PushType.recommend', 'recommand', 'recommend', '추천', 'PSTP003') THEN 'recommand'
      ELSE data->>'pushType'
    END,
    COALESCE(u.uid, data->>'receiveId'),
    data->>'title',
    data->>'message',
    fn_safe_timestamp(data->>'sendAt'),
    CASE WHEN fn_safe_boolean(data->>'isSend') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'sendedAt'),
    NULL,
    data->>'eventWhenClick',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_pushes p
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = p.data->>'receiveId'
  ON CONFLICT (user_push_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_user_push');
END;
$$;


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


-- migrate_fs_notifications.sql
-- Firestore fs_notifications 업무 통합 프로시저 모음

-- migrate_fs_notifications_to_tb_notification.sql
-- Firestore fs_notifications -> tb_notification 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_notifications_to_tb_notification()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_notification_notification_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_notification RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_notification (
    notification_id,
    receiver_uid,
    notification_title,
    notification_content,
    notification_topic,
    event_click,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
     nextval('seq_tb_notification_notification_id')::text,
    COALESCE(u.uid, data->>'receiverUid'),
    data->>'title',
    data->>'message',
    data->>'topic',
    data->>'eventWhenClick',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_notifications n
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = n.data->>'receiverUid'
  ON CONFLICT (notification_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_notification');
END;
$$;

-- =====================================================
-- migrate_fs_users_notificationcenters_to_tb_notification_center.sql
-- =====================================================
-- Firestore fs_users__notificationcenters -> tb_notification_center 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_notificationcenters_to_tb_notification_center()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_notification_center_notification_center_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_notification_center RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_notification_center (
    notification_center_id,
    notification_topic,
    event_click,
    notification_type_code,
    notification_title,
    notification_content,
    receiver_uid,
    appointment_id,
    appointment_at,
    designer_name,
    user_name,
    notification_read_yn,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_notification_center_notification_center_id')::text,
    CASE
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.userCancel', 'userCancel', '고객 취소', 'NTTP001') THEN 'userCancel'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.userAppointment', 'userAppointment', '고객 예약', 'NTTP002') THEN 'userAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.userModifyAppointment', 'userModifyAppointment', '고객 수정', 'NTTP003') THEN 'userModifyAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.designerCancel', 'designerCancel', '디자이너 취소', 'NTTP004') THEN 'designerCancel'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.designerAppointment', 'designerAppointment', '디자이너 예약', 'NTTP005') THEN 'designerAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.designerModifyAppointment', 'designerModifyAppointment', '디자이너 수정', 'NTTP006') THEN 'designerModifyAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.cofirmAppointment', 'cofirmAppointment', '고객 예약요청', 'NTTP007') THEN 'cofirmAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.finishAppointment', 'finishAppointment', '시술 완료', 'NTTP008') THEN 'finishAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.authComplete', 'authComplete', '면허증 확인 완료', 'NTTP009') THEN 'authComplete'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.authReject', 'authReject', '면허증 거절', 'NTTP010') THEN 'authReject'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.authWait', 'authWait', '면허증 확인 중', 'NTTP011') THEN 'authWait'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.webNotification', 'webNotification', '관리자 웹 발송', 'NTTP012') THEN 'webNotification'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.acceptOffer', 'acceptOffer', '디자이너 제안 수락', 'NTTP013') THEN 'acceptOffer'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.cofirmOffer', 'cofirmOffer', '고객 제안 확정', 'NTTP014') THEN 'cofirmOffer'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.confirmSignupDesigner', 'confirmSignupDesigner', '디자이너 가입 확인', 'NTTP015') THEN 'confirmSignupDesigner'
      ELSE data->>'notificationType'
    END,
    data->>'eventWhenClick',
    CASE
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.userCancel', 'userCancel', '고객 취소', 'NTTP001') THEN 'userCancel'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.userAppointment', 'userAppointment', '고객 예약', 'NTTP002') THEN 'userAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.userModifyAppointment', 'userModifyAppointment', '고객 수정', 'NTTP003') THEN 'userModifyAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.designerCancel', 'designerCancel', '디자이너 취소', 'NTTP004') THEN 'designerCancel'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.designerAppointment', 'designerAppointment', '디자이너 예약', 'NTTP005') THEN 'designerAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.designerModifyAppointment', 'designerModifyAppointment', '디자이너 수정', 'NTTP006') THEN 'designerModifyAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.cofirmAppointment', 'cofirmAppointment', '고객 예약요청', 'NTTP007') THEN 'cofirmAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.finishAppointment', 'finishAppointment', '시술 완료', 'NTTP008') THEN 'finishAppointment'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.authComplete', 'authComplete', '면허증 확인 완료', 'NTTP009') THEN 'authComplete'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.authReject', 'authReject', '면허증 거절', 'NTTP010') THEN 'authReject'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.authWait', 'authWait', '면허증 확인 중', 'NTTP011') THEN 'authWait'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.webNotification', 'webNotification', '관리자 웹 발송', 'NTTP012') THEN 'webNotification'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.acceptOffer', 'acceptOffer', '디자이너 제안 수락', 'NTTP013') THEN 'acceptOffer'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.cofirmOffer', 'cofirmOffer', '고객 제안 확정', 'NTTP014') THEN 'cofirmOffer'
      WHEN TRIM(COALESCE(data->>'notificationType','')) IN ('NotificationType.confirmSignupDesigner', 'confirmSignupDesigner', '디자이너 가입 확인', 'NTTP015') THEN 'confirmSignupDesigner'
      ELSE data->>'notificationType'
    END,
    COALESCE(data->>'title', data->>'hairTitle'),
    data->>'message',
    COALESCE(u.uid, COALESCE(data->>'receiverUid', parent_doc_id)),
    COALESCE(a.appointment_id, data->>'appointmentId'),
    fn_safe_timestamp(data->'appointmentModel'->>'startAt'),
    COALESCE(data->>'desingerName', data->'appointmentModel'->>'designerName'),
    data->'appointmentModel'->>'userName',
    CASE WHEN fn_safe_boolean(COALESCE(data->>'notificationCheck', data->>'readYn', data->>'isRead', data->>'read')) THEN 'Y' ELSE 'N' END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__notificationcenters n
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = COALESCE(n.data->>'receiverUid', n.parent_doc_id)
  LEFT JOIN jindamhair.tb_appointment a
    ON a.migration_id = n.data->>'appointmentId'
  ON CONFLICT (notification_center_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_notification_center');
END;
$$;


-- migrate_fs_dynamiclinks.sql
-- Firestore fs_dynamiclinks -> tb_deeplink 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_dynamiclinks_to_tb_deeplink()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_deeplink_deeplink_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_deeplink RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_deeplink (
    deeplink_id,
    deeplink_key,
    deeplink_email,
    deeplink_url,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
      nextval('seq_tb_deeplink_deeplink_id')::text,
    data->>'linkKey',
    data->>'email',
    data->>'link',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_dynamiclinks
  ON CONFLICT (deeplink_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_deeplink');
END;
$$;


-- migrate_fs_configuration.sql
-- Firestore fs_configuration -> tb_configuration 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_configuration_to_tb_configuration()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_configuration RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_configuration (
    aos_last_ver,
    aos_permission_minimum_build_number,
    ios_last_ver,
    ios_permission_minimum_build_number,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn,
    delete_id,
    delete_at
  )
  SELECT
    COALESCE(data->>'aosLastestVersion', data->>'lastest_version', data->>'lastestVersion'),
    COALESCE(data->>'aosAllowMinmumBuildNumber', data->>'allow_minmum_build_number', data->>'allowMinmumBuildNumber'),
    COALESCE(data->>'iosLastestVersion', data->>'lastest_version', data->>'lastestVersion'),
    COALESCE(data->>'iosAllowMinmumBuildNumber', data->>'allow_minmum_build_number', data->>'allowMinmumBuildNumber'),
    COALESCE(data->>'id', doc_id),
    now(),
    'migration',
    NULL,
    'migration',
    'N',
    NULL,
    NULL
  FROM fs_configuration
  WHERE NOT EXISTS (SELECT 1 FROM jindamhair.tb_configuration)
  ORDER BY created_at DESC NULLS LAST
  LIMIT 1;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_configuration');
END;
$$;


-- migrate_fs_chatrooms.sql
-- Firestore fs_chatrooms 업무 통합 프로시저 모음

-- migrate_fs_chatrooms_to_tb_chatroom.sql
-- Firestore fs_chatrooms -> tb_chatroom 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_chatrooms_to_tb_chatroom()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_chatroom_chatroom_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_chatroom RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_chatroom (
    chatroom_id,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
      nextval('seq_tb_chatroom_chatroom_id')::text,
    doc_id,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_chatrooms
  ON CONFLICT (chatroom_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom');
END;
$$;

-- =====================================================
-- migrate_fs_chatrooms_to_tb_chatroom_member.sql
-- =====================================================
-- Firestore fs_chatrooms -> tb_chatroom_member 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_chatrooms_to_tb_chatroom_member()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_chatroom_member_chatroom_member_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_chatroom_member RESTART IDENTITY CASCADE;

  WITH base AS (
    SELECT doc_id, data, created_at, updated_at
    FROM fs_chatrooms
  ),
  members_from_infos AS (
    SELECT
      b.doc_id AS chatroom_id,
      COALESCE(m.value->>'uid', m.key) AS uid,
      m.value->>'title' AS chatroom_name,
      fn_safe_timestamp(m.value->>'lastSeenDt') AS last_read_at,
      b.created_at,
      b.updated_at,
      b.data
    FROM base b
    JOIN LATERAL jsonb_each(b.data->'memberInfos') m
      ON jsonb_typeof(b.data->'memberInfos') = 'object'
  ),
  members_from_ids AS (
    SELECT
      b.doc_id AS chatroom_id,
      uid AS uid,
      NULL::text AS chatroom_name,
      NULL::timestamp AS last_read_at,
      b.created_at,
      b.updated_at,
      b.data
    FROM base b
    JOIN LATERAL jsonb_array_elements_text(b.data->'memberIds') AS uid
      ON jsonb_typeof(b.data->'memberIds') = 'array'
  ),
  all_members AS (
    SELECT * FROM members_from_infos
    UNION
    SELECT * FROM members_from_ids
  ),
  normalized AS (
    SELECT
      chatroom_id,
      uid,
      COALESCE(chatroom_name, data->>'title') AS chatroom_name,
      COALESCE(
        last_read_at,
        fn_safe_timestamp(data->'memberRecentSeenById'->>uid)
      ) AS last_read_at,
      created_at,
      updated_at,
      ROW_NUMBER() OVER (
        PARTITION BY chatroom_id, uid
        ORDER BY
          (chatroom_name IS NOT NULL) DESC,
          last_read_at DESC NULLS LAST
      ) AS rn
    FROM all_members
    WHERE uid IS NOT NULL AND uid <> ''
  )
  INSERT INTO jindamhair.tb_chatroom_member (
    chatroom_member_id,
    chatroom_id,
    uid,
    chatroom_name,
    last_read_at,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT DISTINCT
    nextval('seq_tb_chatroom_member_chatroom_member_id')::text AS chatroom_member_id,
    COALESCE(c.chatroom_id, normalized.chatroom_id),
    COALESCE(u.uid, normalized.uid),
    chatroom_name,
    last_read_at,
    normalized.chatroom_id || '_' || normalized.uid,
    COALESCE(normalized.created_at, now()),
    'migration',
    normalized.updated_at,
    'migration',
    'N'
  FROM normalized
  LEFT JOIN jindamhair.tb_chatroom c
    ON c.migration_id = normalized.chatroom_id
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = normalized.uid
  WHERE normalized.rn = 1
  ON CONFLICT (chatroom_member_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom_member');
END;
$$;


-- migrate_fs_chatmessages.sql
-- Firestore fs_chatrooms__chatmessages -> tb_chatroom_message 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_chatmessages_to_tb_chatroom_message()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_chatroom_message_chat_message_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_chatroom_message RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_chatroom_message (
    chat_message_id,
    chatroom_id,
    write_uid,
    chat_message_type_code,
    chat_message_content_type_code,
    chat_message_content,
    delete_member_uid_arr,
    appointment_id,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_chatroom_message_chat_message_id')::text,
    COALESCE(c.chatroom_id, parent_doc_id),
    COALESCE(u.uid, data->>'authorId'),
    CASE
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.text', 'text', 'txt', '텍스트') THEN 'txt'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.image', 'image', '이미지') THEN 'image'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.video', 'video', '동영상') THEN 'video'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.file', 'file', '파일') THEN 'file'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.sound', 'sound', '음원') THEN 'sound'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.emoji', 'emoji', '이모티콘') THEN 'emoji'
      ELSE data->>'messageType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'messageTextType','')) IN ('MessageTextType.basic', 'basic', '기본') THEN 'basic'
      WHEN TRIM(COALESCE(data->>'messageTextType','')) IN ('MessageTextType.review', 'review', '후기') THEN 'review'
      WHEN TRIM(COALESCE(data->>'messageTextType','')) = '' THEN 'basic'
      ELSE data->>'messageTextType'
    END,
    data->>'message',
    CASE
      WHEN jsonb_typeof(data->'deleteMemberIds') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'deleteMemberIds'))
      ELSE NULL
    END,
    COALESCE(a.appointment_id, data->>'appointmentId'),
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_chatrooms__chatmessages m
  LEFT JOIN jindamhair.tb_chatroom c
    ON c.migration_id = m.parent_doc_id
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = m.data->>'authorId'
  LEFT JOIN jindamhair.tb_appointment a
    ON a.migration_id = m.data->>'appointmentId'
  WHERE COALESCE(fn_safe_timestamp(m.data->>'createAt'), m.created_at) >= TIMESTAMP '2026-01-01 00:00:00'
    AND COALESCE(fn_safe_timestamp(m.data->>'createAt'), m.created_at) < TIMESTAMP '2027-01-01 00:00:00'
  ON CONFLICT (chat_message_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom_message');
  PERFORM jindamhair.normalize_blank_array_to_null('jindamhair', 'tb_chatroom_message');
END;
$$;


-- migrate_fs_banners.sql
-- Firestore fs_banners -> tb_banner 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_banners_to_tb_banner()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_banner_banner_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_banner RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_banner (
    banner_id,
    banner_title,
    banner_content,
    banner_layer_height,
    display_start_at,
    display_end_at,
    sort_order,
    banner_type_code,
    banner_display_position_code,
    banner_display_target_code,
    banner_display_status_code,
    banner_display_time_code,
    banner_icon_code,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_banner_banner_id')::text,
    data->>'title',
    data->>'content',
    (data->>'layerHeight')::numeric,
    fn_safe_timestamp(data->>'displayStartAt'),
    fn_safe_timestamp(data->>'displayEndAt'),
    (data->>'sort')::numeric,
    CASE
      WHEN TRIM(COALESCE(data->>'bannerType','')) IN ('BannerType.banner', 'banner', '배너', 'BNTP001') THEN 'banner'
      WHEN TRIM(COALESCE(data->>'bannerType','')) IN ('BannerType.layer', 'layer', '레이어팝업', 'BNTP002') THEN 'layer'
      ELSE data->>'bannerType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'displayPositionType','')) IN ('DisplayPositionType.main', 'main', '메인', 'BDPT001') THEN 'main'
      WHEN TRIM(COALESCE(data->>'displayPositionType','')) IN ('DisplayPositionType.notice', 'notice', '공지', 'BDPT002') THEN 'notice'
      WHEN TRIM(COALESCE(data->>'displayPositionType','')) IN ('DisplayPositionType.customerList', 'customerList', '고객목록', 'BDPT003') THEN 'customerList'
      ELSE data->>'displayPositionType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'displayTargetUserType','')) IN ('DisplayTargetUserType.all', 'all', '전체', 'BDTG001') THEN 'all'
      WHEN TRIM(COALESCE(data->>'displayTargetUserType','')) IN ('DisplayTargetUserType.customer', 'customer', '고객', 'BDTG002') THEN 'customer'
      WHEN TRIM(COALESCE(data->>'displayTargetUserType','')) IN ('DisplayTargetUserType.designer', 'designer', '디자이너', 'BDTG003') THEN 'designer'
      ELSE data->>'displayTargetUserType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'displayType','')) IN ('DisplayType.visible', 'visible', '노출', 'BDST001') THEN 'visible'
      WHEN TRIM(COALESCE(data->>'displayType','')) IN ('DisplayType.hidden', 'hidden', '미노출', 'BDST002') THEN 'hidden'
      ELSE data->>'displayType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'displayTimeType','')) IN ('DisplayTimeType.always', 'always', '항상', 'BDTM001') THEN 'always'
      WHEN TRIM(COALESCE(data->>'displayTimeType','')) IN ('DisplayTimeType.date', 'date', '시간 조건', 'BDTM002') THEN 'date'
      ELSE data->>'displayTimeType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'iconType','')) IN ('IconType.none', 'none', '없음', 'BNIC001') THEN 'none'
      WHEN TRIM(COALESCE(data->>'iconType','')) IN ('IconType.notice', 'notice', '공지사항', 'BNIC002') THEN 'notice'
      WHEN TRIM(COALESCE(data->>'iconType','')) IN ('IconType.event', 'event', '이벤트', 'BNIC003') THEN 'event'
      WHEN TRIM(COALESCE(data->>'iconType','')) IN ('IconType.discount', 'discount', '할인', 'BNIC004') THEN 'discount'
      WHEN TRIM(COALESCE(data->>'iconType','')) IN ('IconType.calendar', 'calendar', '일정', 'BNIC005') THEN 'calendar'
      WHEN TRIM(COALESCE(data->>'iconType','')) IN ('IconType.tag', 'tag', '가격 태그', 'BNIC006') THEN 'tag'
      ELSE data->>'iconType'
    END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_banners
  ON CONFLICT (banner_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_banner');
END;
$$;


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
