-- common_functions.sql
-- 공통 함수 정의 (Migration 공용)
-- 필요 시 선택적으로 실행

-- 문자열 Timestamp를 안전하게 timestamp로 변환 (UTC+9 기준)
CREATE OR REPLACE FUNCTION fn_safe_timestamp(val text)
RETURNS timestamp AS $$
BEGIN
  IF val IS NULL OR trim(val) = '' THEN
    RETURN NULL;
  END IF;
  RETURN (val::timestamptz AT TIME ZONE 'Asia/Seoul')::timestamp;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 문자열 Boolean을 안전하게 boolean으로 변환
CREATE OR REPLACE FUNCTION fn_safe_boolean(val text)
RETURNS boolean AS $$
BEGIN
  IF val IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN val::boolean;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;



create schema if not exists jindamhair;

create or replace function jindamhair.try_timestamptz(p_text text)
returns timestamptz
language plpgsql
immutable
as $$
declare
  v text := nullif(btrim(p_text), '');
begin
  if v is null then
    return null;
  end if;

  -- epoch millis (13자리)
  if v ~ '^\d{13}$' then
    return to_timestamp((v::numeric) / 1000.0);
  end if;

  -- epoch seconds (10자리)
  if v ~ '^\d{10}$' then
    return to_timestamp(v::numeric);
  end if;

  -- ISO-8601 or timestamptz cast
  return v::timestamptz;

exception
  when others then
    return null;
end;
$$;

-- 공백 문자열 -> NULL 치환 (PK 제외, 문자형 컬럼 대상)
create or replace function jindamhair.normalize_blank_to_null(p_schema text, p_table text)
returns void
language plpgsql
as $$
declare
  rec record;
  pk_cols text[];
  set_exprs text := '';
begin
  select array_agg(att.attname::text order by att.attnum)
    into pk_cols
  from pg_index idx
  join pg_attribute att
    on att.attrelid = idx.indrelid
   and att.attnum = any(idx.indkey)
  join pg_class cls on cls.oid = idx.indrelid
  join pg_namespace nsp on nsp.oid = cls.relnamespace
  where idx.indisprimary
    and nsp.nspname = p_schema
    and cls.relname = p_table;

  for rec in
    select column_name
    from information_schema.columns
    where table_schema = p_schema
      and table_name = p_table
      and data_type in ('character varying', 'character', 'text')
  loop
    if pk_cols is not null and rec.column_name = any(pk_cols) then
      continue;
    end if;
    if set_exprs <> '' then
      set_exprs := set_exprs || ', ';
    end if;
    set_exprs := set_exprs || format('%I = NULLIF(BTRIM(%I), '''')', rec.column_name, rec.column_name);
  end loop;

  if set_exprs <> '' then
    execute format('UPDATE %I.%I SET %s', p_schema, p_table, set_exprs);
  end if;
end;
$$;

-- 배열 컬럼(문자 배열) 내 공백/빈값 제거 후 빈 배열 -> NULL 치환
create or replace function jindamhair.normalize_blank_array_to_null(p_schema text, p_table text)
returns void
language plpgsql
as $$
declare
  rec record;
  set_exprs text := '';
begin
  for rec in
    select column_name
    from information_schema.columns
    where table_schema = p_schema
      and table_name = p_table
      and data_type = 'ARRAY'
      and udt_name in ('_varchar', '_text', '_bpchar')
  loop
    if set_exprs <> '' then
      set_exprs := set_exprs || ', ';
    end if;
    set_exprs := set_exprs || format(
      '%I = CASE WHEN %I IS NULL THEN NULL ELSE NULLIF(ARRAY(SELECT NULLIF(BTRIM(x), '''') FROM unnest(%I) AS x WHERE NULLIF(BTRIM(x), '''') IS NOT NULL), ''{}'') END',
      rec.column_name,
      rec.column_name,
      rec.column_name
    );
  end loop;

  if set_exprs <> '' then
    execute format('UPDATE %I.%I SET %s', p_schema, p_table, set_exprs);
  end if;
end;
$$;

-- 시퀀스 일괄 초기화 (RESTART WITH 1)
create or replace function jindamhair.reset_migration_sequences_to_1()
returns void
language plpgsql
as $$
declare
  seq_list text[] := array[
    'seq_tb_admin_notification_admin_notification_id',
    'seq_tb_appointment_appointment_id',
    'seq_tb_appointment_sign_appointment_sign_id',
    'seq_tb_appointment_style_hair_style_id',
    'seq_tb_appointment_treatment_appointment_treatment_id',
    'seq_tb_banner_banner_id',
    'seq_tb_chatroom_chatroom_id',
    'seq_tb_chatroom_member_chatroom_member_id',
    'seq_tb_chatroom_message_chat_message_id',
    'seq_tb_code_group_code_group_id',
    'seq_tb_code_item_code_item_id',
    'seq_tb_deeplink_deeplink_id',
    'seq_tb_designer_off_off_id',
    'seq_tb_designer_review_designer_review_id',
    'seq_tb_designer_shop_designer_shop_id',
    'seq_tb_desinger_style_add_designer_style_add_id',
    'seq_tb_desinger_style_hair_style_id',
    'seq_tb_desinger_treatment_add_designer_treatment_add_id',
    'seq_tb_desinger_treatment_designer_treatment_id',
    'seq_tb_file_file_id',
    'seq_tb_log_error_idx',
    'seq_tb_notification_center_notification_center_id',
    'seq_tb_notification_notification_id',
    'seq_tb_offer_designer_offer_designer_id',
    'seq_tb_offer_offer_id',
    'seq_tb_offer_treatment_offer_treatment_id',
    'seq_tb_payment_payment_id',
    'seq_tb_recommand_recommand_id',
    'seq_tb_review_review_id',
    'seq_tb_shop_shop_id',
    'seq_tb_treatment_class_treatment_class_id',
    'seq_tb_treatment_treatment_class_id',
    'seq_tb_treatment_treatment_id',
    'seq_tb_user_bookmark_user_bookmark_id',
    'seq_tb_user_push_user_push_id'
  ];
  seq_name text;
begin
  foreach seq_name in array seq_list loop
    execute format('alter sequence if exists jindamhair.%I restart with 1', seq_name);
  end loop;
end;
$$;

-- migrate_fs_alerts.sql
-- Firestore fs_alerts -> tb_admin_notification 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_alerts_to_tb_admin_notification()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_admin_notification_admin_notification_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_admin_notification RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_admin_notification (
    admin_notification_id,
    notification_sender_type_code,
    notification_receiver_type_code,
    notification_send_method_code,
    notification_send_period_type_code,
    notification_title,
    notification_content,
    send_at,
    send_yn,
    send_complete_at,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_admin_notification_admin_notification_id')::text,
    CASE
      WHEN TRIM(COALESCE(data->>'sendUserType','')) IN ('SendUserType.manage', 'manage', '관리자', 'NTST001') THEN 'manage'
      WHEN TRIM(COALESCE(data->>'sendUserType','')) IN ('SendUserType.designer', 'designer', '디자이너', 'NTST002') THEN 'designer'
      ELSE data->>'sendUserType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'targetUserType','')) IN ('TargetUserType.all', 'all', '전체', 'NTRT001') THEN 'all'
      WHEN TRIM(COALESCE(data->>'targetUserType','')) IN ('TargetUserType.designer', 'designer', '디자이너', 'NTRT002') THEN 'designer'
      WHEN TRIM(COALESCE(data->>'targetUserType','')) IN ('TargetUserType.customer', 'customer', '고객', 'NTRT003') THEN 'customer'
      ELSE data->>'targetUserType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'sendMethodType','')) IN ('SendMethodType.all', 'all', '전체', 'NTSM001') THEN 'all'
      WHEN TRIM(COALESCE(data->>'sendMethodType','')) IN ('SendMethodType.push', 'push', '푸시', 'NTSM002') THEN 'push'
      WHEN TRIM(COALESCE(data->>'sendMethodType','')) IN ('SendMethodType.sms', 'sms', '메시지', 'NTSM003') THEN 'sms'
      ELSE data->>'sendMethodType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'sendPeriodType','')) IN ('SendPeriodType.immediately', 'immediately', '즉시', 'NSPT001') THEN 'immediately'
      WHEN TRIM(COALESCE(data->>'sendPeriodType','')) IN ('SendPeriodType.appointment', 'appointment', '예약', 'NSPT002') THEN 'appointment'
      ELSE data->>'sendPeriodType'
    END,
    data->>'title',
    data->>'message',
    fn_safe_timestamp(data->>'sendAt'),
    CASE WHEN fn_safe_boolean(data->>'successYn') THEN 'Y' ELSE 'N' END,
    NULL,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_alerts
  ON CONFLICT (admin_notification_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_admin_notification');
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


-- migrate_fs_statistics.sql
-- Firestore fs_statistics -> tb_recommand 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_statistics_to_tb_recommand()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_recommand_recommand_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_recommand RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_recommand (
    recommand_id,
    uid,
    recommand_count,
    recommand_join_uid_arr,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_recommand_recommand_id')::text,
    COALESCE(u.uid, data->>'designerUid'),
    NULLIF(data->>'designerRecommendCount', '')::numeric,
    CASE
      WHEN jsonb_typeof(data->'joinUserUids') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'joinUserUids'))
      ELSE NULL
    END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_statistics s
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = s.data->>'designerUid'
  ON CONFLICT (recommand_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_recommand');
  PERFORM jindamhair.normalize_blank_array_to_null('jindamhair', 'tb_recommand');
END;
$$;


-- migrate_fs_stores.sql
-- Firestore fs_stores -> tb_shop 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_stores_to_tb_shop()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_shop_shop_id restart with 1';
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
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
      nextval('seq_tb_shop_shop_id')::text,
    data->>'title',
    data->>'description',
    data->>'address',
    data->>'addressDetail',
    COALESCE(data->>'contactNumber', data->>'phoneNum'),
    data->>'gpsX',
    data->>'gpsY',
    data->>'postCode',
    CASE
      WHEN data->>'storeStatusType' = 'StoreStatusType.active' THEN 'Y'
      WHEN data->>'storeStatusType' = 'StoreStatusType.unused' THEN 'N'
      WHEN data->>'storeStatusType' = 'StoreStatusType.delete' THEN 'N'
      ELSE 'Y'
    END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    CASE
      WHEN data->>'storeStatusType' = 'StoreStatusType.delete' THEN 'Y'
      ELSE 'N'
    END
  FROM fs_stores
  ON CONFLICT (shop_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_shop');
END;
$$;


-- migrate_fs_treatmentclassfications.sql
-- Firestore fs_treatmentclassfications -> tb_treatment_class 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_treatmentclassfications_to_tb_treatment_class()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_treatment_treatment_class_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_treatment_class RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_treatment_class (
    treatment_class_id,
    treatment_code,
    treatment_name,
    treatment_level,
    treatment_code_1,
    treatment_name_1,
    treatment_code_2,
    treatment_name_2,
    treatment_code_3,
    treatment_name_3,
    sort_order,
    use_yn,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_treatment_treatment_class_id')::text,
    data->>'code',
    data->>'title',
    NULLIF(data->>'level', '')::numeric,
    data->>'levelCode1',
    data->>'levelTitle1',
    data->>'levelCode2',
    data->>'levelTitle2',
    data->>'levelCode3',
    data->>'levelTitle3',
    NULLIF(data->>'sort', '')::numeric,
    CASE WHEN fn_safe_boolean(data->>'useYn') THEN 'Y' ELSE 'N' END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_treatmentclassfications
  ON CONFLICT (treatment_class_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_treatment_class');
END;
$$;


-- migrate_fs_treatments.sql
-- Firestore fs_treatments -> tb_treatment 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_treatments_to_tb_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_treatment_treatment_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_treatment RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_treatment (
    treatment_id,
    treatment_code,
    treatment_name,
    treatment_level,
    sort_order,
    offer_minimum_amount,
    use_yn,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
      nextval('seq_tb_treatment_treatment_id')::text,
    data->>'code',
    data->>'title',
    NULLIF(data->>'level', '')::numeric,
    NULLIF(data->>'sort', '')::numeric,
    NULLIF(data->>'offerMinPrice', '')::numeric,
    CASE WHEN fn_safe_boolean(data->>'useYn') THEN 'Y' ELSE 'N' END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_treatments
  ON CONFLICT (treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_treatment');
END;
$$;


-- migrate_fs_users.sql
-- Firestore fs_users 업무 통합 프로시저 모음

-- migrate_fs_users_to_tb_user.sql
-- Firestore fs_users -> tb_user 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_user()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_file_file_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_file RESTART IDENTITY CASCADE;
  TRUNCATE TABLE jindamhair.tb_user RESTART IDENTITY CASCADE;

  -- 파일 URL 선적재 (file_id=시퀀스, migration_id=그룹키, 배열은 동일 file_id + sort_order)
  WITH groups AS (
    SELECT DISTINCT group_key
    FROM (
      SELECT COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) || '_profile' AS group_key
      FROM fs_users u
      WHERE COALESCE(NULLIF(TRIM(u.data->>'imageUrl'), ''), '') <> ''
      UNION ALL
      SELECT COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) || '_license' AS group_key
      FROM fs_users u
      WHERE COALESCE(NULLIF(TRIM(u.data->>'designerLicenseImageUrl'), ''), '') <> ''
      UNION ALL
      SELECT COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) || '_designerPhotos' AS group_key
      FROM fs_users u
      WHERE CASE
        WHEN jsonb_typeof(u.data->'designerPhotos') = 'array'
          THEN jsonb_array_length(u.data->'designerPhotos') > 0
        ELSE false
      END
    ) g
  ),
  group_ids AS (
    SELECT group_key, nextval('seq_tb_file_file_id')::text AS file_id
    FROM groups
  ),
  file_rows AS (
    SELECT
      gid.file_id,
      src.sort_order,
      src.url,
      gid.group_key AS migration_id
    FROM (
      SELECT
        COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) || '_profile' AS group_key,
        1::numeric AS sort_order,
        u.data->>'imageUrl' AS url
      FROM fs_users u
      UNION ALL
      SELECT
        COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) || '_license' AS group_key,
        1::numeric AS sort_order,
        u.data->>'designerLicenseImageUrl' AS url
      FROM fs_users u
      UNION ALL
      SELECT
        COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) || '_designerPhotos' AS group_key,
        dp.ord::numeric AS sort_order,
        dp.url AS url
      FROM fs_users u
      JOIN LATERAL jsonb_array_elements_text(u.data->'designerPhotos') WITH ORDINALITY AS dp(url, ord)
        ON jsonb_typeof(u.data->'designerPhotos') = 'array'
    ) src
    JOIN group_ids gid
      ON gid.group_key = src.group_key
    WHERE src.url IS NOT NULL AND src.url <> ''
  )
  INSERT INTO jindamhair.tb_file (
    file_id, sort_order, file_type_code, org_file_name, convert_file_name,
    file_path, file_size, migration_id, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
  )
  SELECT
    fr.file_id,
    fr.sort_order,
    'image',
    NULL,
    NULL,
    fr.url,
    NULL,
    fr.migration_id,
    now(),
    'migration',
    NULL,
    NULL,
    'N',
    NULL,
    NULL
  FROM file_rows fr
  ON CONFLICT (file_id, sort_order) DO NOTHING;

  INSERT INTO jindamhair.tb_user (
    uid,
    user_email,
    user_contact,
    user_name,
    user_nickname,
    user_status_code,
    user_type_code,
    user_brdt,
    user_join_type_code,
    push_token,
    last_login_at,
    interception_user_id_arr,
    prvcplc_agree_yn,
    terms_agree_yn,
    all_notification_reception_yn,
    all_notification_reception_at,
    notice_notification_reception_yn,
    notice_notification_reception_at,
    marketing_notification_reception_yn,
    marketing_notification_reception_at,
    offer_notification_reception_yn,
    offer_notification_reception_at,
    chat_notification_reception_yn,
    chat_notification_reception_at,
    appointment_notification_reception_yn,
    appointment_notification_reception_at,
    position_addr,
    position_latt,
    position_lngt,
    position_distance,
    profile_photo_file_id,
    designer_appr_status_code,
    designer_introduce_content,
    designer_tag_arr,
    designer_work_status_code,
    designer_open_day_arr,
    designer_open_time_arr,
    designer_close_time_arr,
    designer_off_date_arr,
    designer_appointment_automatic_confirm_yn,
    designer_applink_url,
    designer_detail_photo_file_id,
    designer_account_brand_code,
    designer_license_photo_file_id,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'uid', data->>'id', doc_id),
    data->>'email',
    data->>'phoneNum',
    data->>'name',
    data->>'nickname',
    CASE
      WHEN TRIM(COALESCE(data->>'userStatusType','')) IN ('UserStatusType.unknown', 'unknown', '미확인', 'USST001') THEN 'unknown'
      WHEN TRIM(COALESCE(data->>'userStatusType','')) IN ('UserStatusType.temp', 'temp', '임시 가입', 'USST002') THEN 'temp'
      WHEN TRIM(COALESCE(data->>'userStatusType','')) IN ('UserStatusType.active', 'active', '가입 완료', '가입완료', 'USST003') THEN 'active'
      WHEN TRIM(COALESCE(data->>'userStatusType','')) IN ('UserStatusType.dormant', 'dormant', '휴면', 'USST004') THEN 'dormant'
      WHEN TRIM(COALESCE(data->>'userStatusType','')) IN ('UserStatusType.withdrawn', 'withdrawn', '탈회', '탈퇴', 'USST005') THEN 'withdrawn'
      WHEN TRIM(COALESCE(data->>'userStatusType','')) IN ('UserStatusType.blacklisted', 'blacklisted', '블랙리스트', 'USST006') THEN 'blacklisted'
      WHEN TRIM(COALESCE(data->>'userStatusType','')) IN ('UserStatusType.removed', 'removed', '관리자 삭제', 'USST007') THEN 'removed'
      ELSE data->>'userStatusType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'userType','')) IN ('UserType.customer', 'customer', '고객', 'USTP001') THEN 'customer'
      WHEN TRIM(COALESCE(data->>'userType','')) IN ('UserType.designer', 'designer', '디자이너', 'USTP002') THEN 'designer'
      ELSE data->>'userType'
    END,
    data->>'birth',
    CASE
      WHEN TRIM(COALESCE(
        regexp_replace(
          BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
          '^SignUpMethod\.',
          'SignUpMethodType.'
        ),
        ''
      )) IN ('SignUpMethodType.email', 'SignUpMethod.email', 'email', '이메일', 'UJTP001') THEN 'email'
      WHEN TRIM(COALESCE(
        regexp_replace(
          BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
          '^SignUpMethod\.',
          'SignUpMethodType.'
        ),
        ''
      )) IN ('SignUpMethodType.apple', 'SignUpMethod.apple', 'apple', '애플', 'UJTP002') THEN 'apple'
      WHEN TRIM(COALESCE(
        regexp_replace(
          BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
          '^SignUpMethod\.',
          'SignUpMethodType.'
        ),
        ''
      )) IN ('SignUpMethodType.google', 'SignUpMethod.google', 'google', '구글', 'UJTP003') THEN 'google'
      WHEN TRIM(COALESCE(
        regexp_replace(
          BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
          '^SignUpMethod\.',
          'SignUpMethodType.'
        ),
        ''
      )) IN ('SignUpMethodType.facebook', 'SignUpMethod.facebook', 'facebook', '페이스북', 'UJTP004') THEN 'facebook'
      WHEN TRIM(COALESCE(
        regexp_replace(
          BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
          '^SignUpMethod\.',
          'SignUpMethodType.'
        ),
        ''
      )) IN ('SignUpMethodType.kakao', 'SignUpMethod.kakao', 'kakao', '카카오', 'UJTP005') THEN 'kakao'
      WHEN TRIM(COALESCE(
        regexp_replace(
          BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
          '^SignUpMethod\.',
          'SignUpMethodType.'
        ),
        ''
      )) IN ('SignUpMethodType.naver', 'SignUpMethod.naver', 'naver', '네이버', 'UJTP006') THEN 'naver'
      WHEN TRIM(COALESCE(
        regexp_replace(
          BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
          '^SignUpMethod\.',
          'SignUpMethodType.'
        ),
        ''
      )) LIKE 'UJTP%' THEN NULL
      ELSE regexp_replace(
        BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
        '^SignUpMethod\.',
        'SignUpMethodType.'
      )
    END,
    data->>'pushToken',
    fn_safe_timestamp(data->>'lastLoginAt'),
    CASE
      WHEN jsonb_typeof(data->'blockIds') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'blockIds'))
      ELSE NULL
    END,
    CASE WHEN fn_safe_boolean(data->>'isAgreePrivacy') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(data->>'isAgreeTerms') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(data->>'isNotificationAll') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'isNotificationAllAt'),
    CASE WHEN fn_safe_boolean(data->>'isNotificationNotice') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'isNotificationNoticeAt'),
    CASE WHEN fn_safe_boolean(data->>'isNotificationAdvertisement') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'isNotificationAdvertisementAt'),
    CASE WHEN fn_safe_boolean(data->>'isNotificationOffer') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'isNotificationOfferAt'),
    CASE WHEN fn_safe_boolean(data->>'isNotificationChat') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'isNotificationChatAt'),
    CASE WHEN fn_safe_boolean(data->>'isNotificationAppointment') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'isNotificationAppointmentAt'),
    data->>'locationAddress',
    data->>'locationLatitude',
    data->>'locationLongitude',
    data->>'locationDistance',
    CASE
      WHEN COALESCE(NULLIF(TRIM(data->>'imageUrl'), ''), '') <> '' THEN (
        SELECT f.file_id
        FROM jindamhair.tb_file f
        WHERE f.migration_id = COALESCE(data->>'uid', data->>'id', doc_id) || '_profile'
          AND f.sort_order = 1
        LIMIT 1
      )
      ELSE NULL
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'designerAuthStatusType','')) IN ('DesignerAuthStatusType.preAuth', 'preAuth', '미인증', 'DAST001') THEN 'preAuth'
      WHEN TRIM(COALESCE(data->>'designerAuthStatusType','')) IN ('DesignerAuthStatusType.authComplete', 'authComplete', '승인', 'DAST002') THEN 'authComplete'
      WHEN TRIM(COALESCE(data->>'designerAuthStatusType','')) IN ('DesignerAuthStatusType.authReject', 'authReject', '거절', 'DAST003') THEN 'authReject'
      WHEN TRIM(COALESCE(data->>'designerAuthStatusType','')) IN ('DesignerAuthStatusType.authWait', 'authWait', '대기', 'DAST004') THEN 'authWait'
      ELSE data->>'designerAuthStatusType'
    END,
    data->>'designerInfo',
    CASE
      WHEN jsonb_typeof(data->'designerTags') = 'array' THEN
        ARRAY(
          SELECT DISTINCT tag
          FROM jsonb_array_elements_text(data->'designerTags') AS elem
          CROSS JOIN LATERAL regexp_split_to_table(elem, '#') AS tag
          WHERE BTRIM(tag) <> ''
        )
      WHEN data ? 'designerTags' THEN
        ARRAY(
          SELECT tag
          FROM regexp_split_to_table(data->>'designerTags', '#') AS tag
          WHERE BTRIM(tag) <> ''
        )
      ELSE NULL
    END,
    CASE
      WHEN data ? 'designerIsWork' THEN
        CASE WHEN fn_safe_boolean(data->>'designerIsWork') THEN 'work' ELSE 'close' END
      ELSE NULL
    END,
    CASE
      WHEN jsonb_typeof(data->'designerOpenDays') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'designerOpenDays'))
      ELSE NULL
    END,
    CASE
      WHEN jsonb_typeof(data->'designerOpenTime') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'designerOpenTime'))
      ELSE NULL
    END,
    CASE
      WHEN jsonb_typeof(data->'designerCloseTime') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'designerCloseTime'))
      ELSE NULL
    END,
    CASE
      WHEN jsonb_typeof(data->'designerAllCloseTime') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'designerAllCloseTime'))
      ELSE NULL
    END,
    CASE WHEN fn_safe_boolean(data->>'designerAutoConfirmAppointment') THEN 'Y' ELSE 'N' END,
    data->>'designerDetailDynamicLinkUrl',
    CASE
      WHEN jsonb_typeof(data->'designerPhotos') = 'array'
        AND jsonb_array_length(data->'designerPhotos') > 0 THEN (
        SELECT f.file_id
        FROM jindamhair.tb_file f
        WHERE f.migration_id = COALESCE(data->>'uid', data->>'id', doc_id) || '_designerPhotos'
          AND f.sort_order = 1
        LIMIT 1
      )
      ELSE NULL
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.unknown', 'unknown', '미확인', 'DABT001') THEN 'unknown'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.kb', 'kb', '국민은행', 'DABT002') THEN 'kb'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.shinhan', 'shinhan', '신한은행', 'DABT003') THEN 'shinhan'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.nh', 'nh', '농협은행', 'DABT004') THEN 'nh'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.ibk', 'ibk', '기업은행', 'DABT005') THEN 'ibk'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.woori', 'woori', '우리은행', 'DABT006') THEN 'woori'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.city', 'city', '씨티은행', 'DABT007') THEN 'city'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.hana', 'hana', '하나은행', 'DABT008') THEN 'hana'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.kakao', 'kakao', '카카오뱅크', 'DABT009') THEN 'kakao'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.toss', 'toss', '토스뱅크', 'DABT010') THEN 'toss'
      WHEN TRIM(COALESCE(data->>'designerAccountBrandType','')) IN ('DesignerAccountBrandType.k', 'k', '케이뱅크', 'DABT011') THEN 'k'
      ELSE data->>'designerAccountBrandType'
    END,
    CASE
      WHEN COALESCE(NULLIF(TRIM(data->>'designerLicenseImageUrl'), ''), '') <> '' THEN (
        SELECT f.file_id
        FROM jindamhair.tb_file f
        WHERE f.migration_id = COALESCE(data->>'uid', data->>'id', doc_id) || '_license'
          AND f.sort_order = 1
        LIMIT 1
      )
      ELSE NULL
    END,
    COALESCE(data->>'uid', data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_users u
  ON CONFLICT (uid) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_user');
  PERFORM jindamhair.normalize_blank_array_to_null('jindamhair', 'tb_user');
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_designer_shop.sql
-- =====================================================
-- Firestore fs_users -> tb_designer_shop 이관 프로시저 (users.stores 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_shop()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_designer_shop_designer_shop_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_designer_shop RESTART IDENTITY CASCADE;

  WITH base AS (
    SELECT doc_id, data, created_at, updated_at
    FROM fs_users
  ),
  primary_shop AS (
    SELECT
      b.doc_id AS owner_doc_id,
      COALESCE(b.data->>'uid', b.data->>'id', b.doc_id) AS uid,
      b.data->>'storeId' AS shop_id,
      b.data->>'storeName' AS shop_name,
      b.data->>'storeAddress' AS shop_addr,
      NULL::text AS shop_addr_detail,
      b.data->>'storePhoneNum' AS shop_contact,
      NULL::text AS position_lngt,
      NULL::text AS position_latt,
      NULL::text AS zipcode,
      'Y'::bpchar AS representative_yn,
      NULL::text AS shop_regist_type_code,
      'Y'::bpchar AS use_yn,
      b.created_at,
      b.updated_at
    FROM base b
    WHERE COALESCE(b.data->>'storeId','') <> ''
  ),
  extra_shops AS (
    SELECT
      b.doc_id AS owner_doc_id,
      COALESCE(b.data->>'uid', b.data->>'id', b.doc_id) AS uid,
      COALESCE(uss.data->>'id', uss.data->>'storeId', uss.doc_id) AS shop_id,
      COALESCE(uss.data->>'title', uss.data->>'name', uss.data->>'storeName') AS shop_name,
      COALESCE(uss.data->>'address', uss.data->>'storeAddress') AS shop_addr,
      uss.data->>'addressDetail' AS shop_addr_detail,
      COALESCE(uss.data->>'contactNumber', uss.data->>'phoneNum', uss.data->>'storePhoneNum') AS shop_contact,
      uss.data->>'gpsX' AS position_lngt,
      uss.data->>'gpsY' AS position_latt,
      uss.data->>'postCode' AS zipcode,
      CASE WHEN fn_safe_boolean(uss.data->>'isRepresentative') THEN 'Y' ELSE 'N' END AS representative_yn,
      uss.data->>'storeAddType' AS shop_regist_type_code,
      'Y'::bpchar AS use_yn,
      COALESCE(uss.created_at, b.created_at) AS created_at,
      COALESCE(uss.updated_at, b.updated_at) AS updated_at
    FROM base b
    JOIN fs_users__stores uss
      ON uss.parent_doc_id = b.doc_id
  ),
  combined AS (
    SELECT * FROM primary_shop
    UNION ALL
    SELECT * FROM extra_shops
  )
  INSERT INTO jindamhair.tb_designer_shop (
    designer_shop_id,
    uid,
    shop_id,
    shop_regist_type_code,
    representative_yn,
    shop_name,
    shop_description,
    shop_addr,
    shop_addr_detail,
    shop_contact,
    position_lngt,
    position_latt,
    zipcode,
    use_yn,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_designer_shop_designer_shop_id')::text AS designer_shop_id,
    COALESCE(u.uid, combined.uid),
    s.shop_id,
    CASE
      WHEN s.shop_id IS NULL THEN 'add'
      ELSE 'basic'
    END,
    representative_yn,
    COALESCE(s.shop_name, uss.data->>'title', combined.shop_name),
    NULL,
    COALESCE(s.shop_addr, uss.data->>'address', combined.shop_addr),
    COALESCE(s.shop_addr_detail, uss.data->>'addressDetail', combined.shop_addr_detail),
    COALESCE(s.shop_contact, uss.data->>'contactNumber', uss.data->>'phoneNum', combined.shop_contact),
    COALESCE(s.position_lngt, uss.data->>'gpsX', combined.position_lngt),
    COALESCE(s.position_latt, uss.data->>'gpsY', combined.position_latt),
    COALESCE(s.zipcode, uss.data->>'postCode', combined.zipcode),
    combined.use_yn,
    combined.uid || '_' || combined.shop_id,
    COALESCE(combined.created_at, now()),
    'migration',
    combined.updated_at,
    'migration',
    'N'
  FROM combined
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = combined.uid
  LEFT JOIN jindamhair.tb_shop s
    ON s.migration_id = combined.shop_id
  LEFT JOIN fs_users__stores uss
    ON uss.parent_doc_id = combined.owner_doc_id
   AND COALESCE(uss.data->>'id', uss.data->>'storeId', uss.doc_id) = combined.shop_id
  WHERE COALESCE(combined.uid,'') <> ''
    AND COALESCE(combined.shop_id,'') <> ''
  ON CONFLICT (designer_shop_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_designer_shop');
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_user_bookmark.sql
-- =====================================================
-- Firestore fs_users -> tb_user_bookmark 이관 프로시저 (favoriteIds 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_user_bookmark()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_user_bookmark_user_bookmark_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_user_bookmark RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_user_bookmark (
    user_bookmark_id,
    uid,
    bookmark_target_user_id,
    user_gender_code,
    user_agg_code,
    user_type_code,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  WITH base AS (
    SELECT
      COALESCE(data->>'uid', data->>'userId', data->>'ownerUid') AS owner_uid,
      COALESCE(data->>'favoriteId', data->>'favoriteUid', data->>'targetUid') AS bookmark_uid,
      data,
      created_at,
      updated_at
    FROM fs_usersfavorites
  )
  SELECT
    nextval('seq_tb_user_bookmark_user_bookmark_id')::text AS user_bookmark_id,
    COALESCE(target.uid, base.bookmark_uid) AS uid,
    COALESCE(owner.uid, base.owner_uid) AS bookmark_target_user_id,
    CASE
      WHEN TRIM(COALESCE(COALESCE(base.data->>'genderType', fav.data->>'genderType'),'')) IN ('GenderType.female', 'female', '여성', 'USGD001') THEN 'female'
      WHEN TRIM(COALESCE(COALESCE(base.data->>'genderType', fav.data->>'genderType'),'')) IN ('GenderType.male', 'male', '남성', 'USGD002') THEN 'male'
      ELSE COALESCE(base.data->>'genderType', fav.data->>'genderType')
    END AS user_gender_code,
    CASE
      WHEN TRIM(COALESCE(COALESCE(base.data->>'ageType', fav.data->>'ageType'),'')) IN ('AgeType.unknown', 'unknown', '미확인', 'USAG001') THEN 'unknown'
      WHEN TRIM(COALESCE(COALESCE(base.data->>'ageType', fav.data->>'ageType'),'')) IN ('AgeType.teenUnder', 'teenUnder', '10대 이하', 'USAG002') THEN 'teenUnder'
      WHEN TRIM(COALESCE(COALESCE(base.data->>'ageType', fav.data->>'ageType'),'')) IN ('AgeType.teen', 'teen', '10대', 'USAG003') THEN 'teen'
      WHEN TRIM(COALESCE(COALESCE(base.data->>'ageType', fav.data->>'ageType'),'')) IN ('AgeType.twenty', 'twenty', '20대', 'USAG004') THEN 'twenty'
      WHEN TRIM(COALESCE(COALESCE(base.data->>'ageType', fav.data->>'ageType'),'')) IN ('AgeType.thirty', 'thirty', '30대', 'USAG005') THEN 'thirty'
      WHEN TRIM(COALESCE(COALESCE(base.data->>'ageType', fav.data->>'ageType'),'')) IN ('AgeType.forty', 'forty', '40대', 'USAG006') THEN 'forty'
      WHEN TRIM(COALESCE(COALESCE(base.data->>'ageType', fav.data->>'ageType'),'')) IN ('AgeType.fifty', 'fifty', '50대', 'USAG007') THEN 'fifty'
      WHEN TRIM(COALESCE(COALESCE(base.data->>'ageType', fav.data->>'ageType'),'')) IN ('AgeType.sixtyUpper', 'sixtyUpper', '60대 이상', 'USAG008') THEN 'sixtyUpper'
      ELSE COALESCE(base.data->>'ageType', fav.data->>'ageType')
    END AS user_agg_code,
    NULL AS user_type_code,
    base.bookmark_uid || '_' || base.owner_uid,
    COALESCE(fn_safe_timestamp(base.data->>'createAt'), base.created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(base.data->>'updateAt'), base.updated_at),
    'migration',
    'N'
  FROM base
  LEFT JOIN jindamhair.tb_user owner
    ON owner.migration_id = base.owner_uid
  LEFT JOIN jindamhair.tb_user target
    ON target.migration_id = base.bookmark_uid
  LEFT JOIN fs_users fav
    ON COALESCE(fav.data->>'uid', fav.data->>'id', fav.doc_id) = base.bookmark_uid
  WHERE COALESCE(base.owner_uid, '') <> ''
    AND COALESCE(base.bookmark_uid, '') <> ''
  ON CONFLICT (user_bookmark_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_user_bookmark');
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_designer_review.sql
-- =====================================================
-- Firestore fs_users -> tb_designer_review 이관 프로시저 (users.reviewCount Map 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_review()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_designer_review_designer_review_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_designer_review RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_designer_review (
    designer_review_id,
    review_type_code,
    review_count,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_designer_review_designer_review_id')::text AS designer_review_id,
    CASE
      WHEN TRIM(COALESCE(review_type_code,'')) IN ('ReviewType.friendlyService', 'friendlyService', '친절한 서비스', 'RVTP001') THEN 'friendlyService'
      WHEN TRIM(COALESCE(review_type_code,'')) IN ('ReviewType.professionalSkill', 'professionalSkill', '전문적인 시술 실력', 'RVTP002') THEN 'professionalSkill'
      WHEN TRIM(COALESCE(review_type_code,'')) IN ('ReviewType.greatStyling', 'greatStyling', '스타일 완성도/만족', 'RVTP003') THEN 'greatStyling'
      WHEN TRIM(COALESCE(review_type_code,'')) IN ('ReviewType.goodCommunication', 'goodCommunication', '상담/소통 만족', 'RVTP004') THEN 'goodCommunication'
      ELSE review_type_code
    END,
    review_count,
    uid || '_' || review_type_code,
    COALESCE(fn_safe_timestamp(user_create_at), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM (
    SELECT
      COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) AS uid,
      u.data->>'createAt' AS user_create_at,
      u.created_at,
      u.updated_at,
      k AS review_type_code,
      CASE
        WHEN (v)::text ~ '^[0-9]+(\\.[0-9]+)?$' THEN (v)::numeric
        ELSE NULL
      END AS review_count
    FROM fs_users u
    JOIN LATERAL jsonb_each_text(u.data->'reviewCount') AS rc(k, v)
      ON jsonb_typeof(u.data->'reviewCount') = 'object'
  ) t
  WHERE uid IS NOT NULL AND uid <> ''
    AND review_type_code IS NOT NULL AND review_type_code <> ''
  ON CONFLICT (designer_review_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_designer_review');
END;
$$;

-- =====================================================
-- migrate_fs_users_menus_to_tb_desinger_treatment.sql
-- =====================================================
-- Firestore fs_users__menus -> tb_desinger_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_menus_to_tb_desinger_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_desinger_treatment_designer_treatment_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_desinger_treatment RESTART IDENTITY CASCADE;

  -- tb_file 시퀀스 동기화 (기존 데이터 존재 시 중복 방지)
  PERFORM setval(
    'jindamhair.seq_tb_file_file_id',
    COALESCE((
      SELECT MAX(file_id::bigint)
      FROM jindamhair.tb_file
      WHERE file_id ~ '^\d+$'
    ), 0) + 1,
    false
  );

  -- 파일 URL 선적재 (file_id=시퀀스, migration_id=그룹키, 배열은 동일 file_id + sort_order)
  WITH groups AS (
    SELECT DISTINCT group_key
    FROM (
      SELECT COALESCE((m.data::jsonb)->>'id', m.doc_id) || '_hairImage' AS group_key
      FROM fs_users__menus m
      WHERE jsonb_typeof((m.data::jsonb)->'hairImageUrl') = 'array'
        AND jsonb_array_length((m.data::jsonb)->'hairImageUrl') > 0
    ) g
  ),
  group_ids AS (
    SELECT group_key, nextval('seq_tb_file_file_id')::text AS file_id
    FROM groups
  ),
  file_rows AS (
    SELECT
      gid.file_id,
      src.sort_order,
      src.url,
      gid.group_key AS migration_id
    FROM (
      SELECT
        COALESCE((m.data::jsonb)->>'id', m.doc_id) || '_hairImage' AS group_key,
        hu.ord::numeric AS sort_order,
        hu.url AS url
      FROM fs_users__menus m
      JOIN LATERAL jsonb_array_elements_text((m.data::jsonb)->'hairImageUrl') WITH ORDINALITY AS hu(url, ord)
        ON jsonb_typeof((m.data::jsonb)->'hairImageUrl') = 'array'
    ) src
    JOIN group_ids gid
      ON gid.group_key = src.group_key
    WHERE src.url IS NOT NULL AND src.url <> ''
  )
  INSERT INTO jindamhair.tb_file (
    file_id, sort_order, file_type_code, org_file_name, convert_file_name,
    file_path, file_size, migration_id, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
  )
  SELECT
    fr.file_id,
    fr.sort_order,
    'image',
    NULL,
    NULL,
    fr.url,
    NULL,
    fr.migration_id,
    now(),
    'migration',
    NULL,
    NULL,
    'N',
    NULL,
    NULL
  FROM file_rows fr
  ON CONFLICT (file_id, sort_order) DO NOTHING;

  INSERT INTO jindamhair.tb_desinger_treatment (
    designer_treatment_id,
    uid,
    treatment_name,
    basic_amount,
    discount_pt,
    discount_amount,
    total_amount,
    treatment_content,
    treatment_require_time,
    treatment_photo_file_id,
    treatment_gender_type_code,
    discount_yn,
    add_yn,
    open_yn,
    sort_order,
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
    nextval('seq_tb_desinger_treatment_designer_treatment_id')::text,
    COALESCE(u.uid, parent_doc_id),
    (m.data::jsonb)->>'title',
    CASE WHEN ((m.data::jsonb)->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'price')::numeric ELSE NULL END,
    CASE WHEN ((m.data::jsonb)->>'percent') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'percent')::numeric ELSE NULL END,
    CASE WHEN ((m.data::jsonb)->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'salePrice')::numeric ELSE NULL END,
    CASE WHEN ((m.data::jsonb)->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'totalPrice')::numeric ELSE NULL END,
    NULL,
    CASE WHEN ((m.data::jsonb)->>'hairTime') ~ '^[0-9]+(\\.[0-9]+)?$' THEN ((m.data::jsonb)->>'hairTime')::numeric ELSE NULL END,
    CASE
      WHEN jsonb_typeof((m.data::jsonb)->'hairImageUrl') = 'array'
        AND jsonb_array_length((m.data::jsonb)->'hairImageUrl') > 0 THEN (
        SELECT f.file_id
        FROM jindamhair.tb_file f
        WHERE f.migration_id = COALESCE((m.data::jsonb)->>'id', m.doc_id) || '_hairImage'
          AND f.sort_order = 1
        LIMIT 1
      )
      ELSE NULL
    END,
    CASE
      WHEN TRIM(COALESCE((m.data::jsonb)->>'hairGenderType','')) IN ('GenderType.all', 'all', '전체', 'TGTP001') THEN 'all'
      WHEN TRIM(COALESCE((m.data::jsonb)->>'hairGenderType','')) IN ('GenderType.female', 'female', '여성', 'TGTP002') THEN 'female'
      WHEN TRIM(COALESCE((m.data::jsonb)->>'hairGenderType','')) IN ('GenderType.male', 'male', '남성', 'TGTP003') THEN 'male'
      ELSE (m.data::jsonb)->>'hairGenderType'
    END,
    CASE WHEN fn_safe_boolean((m.data::jsonb)->>'isSalePrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean((m.data::jsonb)->>'isAddPrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean((m.data::jsonb)->>'isOpenMenu') THEN 'Y' ELSE 'N' END,
    CASE WHEN ((m.data::jsonb)->>'order') ~ '^[0-9]+$' THEN ((m.data::jsonb)->>'order')::numeric ELSE NULL END,
    (m.data::jsonb)->>'levelCode1',
    (m.data::jsonb)->>'levelTitle1',
    (m.data::jsonb)->>'levelCode2',
    (m.data::jsonb)->>'levelTitle2',
    (m.data::jsonb)->>'levelCode3',
    (m.data::jsonb)->>'levelTitle3',
    COALESCE((m.data::jsonb)->>'id', m.doc_id),
    COALESCE(fn_safe_timestamp((m.data::jsonb)->>'createAt'), m.created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus m
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = m.parent_doc_id
  ON CONFLICT (designer_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_desinger_treatment');
END;
$$;

-- =====================================================
-- migrate_fs_users_menus_to_tb_desinger_treatment_add.sql
-- =====================================================
-- Firestore fs_users__menus -> tb_desinger_treatment_add 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_menus_to_tb_desinger_treatment_add()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_desinger_treatment_add_designer_treatment_add_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_desinger_treatment_add RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_desinger_treatment_add (
    designer_treatment_add_id,
    designer_treatment_id,
    hair_add_type_code,
    add_amount,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_desinger_treatment_add_designer_treatment_add_id')::text AS designer_treatment_add_id,
    COALESCE(dt.designer_treatment_id, COALESCE((m.data::jsonb)->>'id', m.doc_id)) AS designer_treatment_id,
    v.hair_add_type_code,
    CASE WHEN v.add_amount_raw ~ '^[0-9]+(\\.[0-9]+)?$' THEN v.add_amount_raw::numeric ELSE NULL END,
    COALESCE((m.data::jsonb)->>'id', m.doc_id) || '_' || v.hair_add_type_code,
    COALESCE(fn_safe_timestamp((m.data::jsonb)->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus m
  LEFT JOIN jindamhair.tb_desinger_treatment dt
    ON dt.migration_id = COALESCE(m.data->>'id', m.doc_id)
  CROSS JOIN LATERAL (
    VALUES
      ('chinLine', (m.data::jsonb)->>'chinPrice'),
      ('shoulderLine', (m.data::jsonb)->>'shoulderPrice'),
      ('chestLine', (m.data::jsonb)->>'chestPrice'),
      ('waistLine', (m.data::jsonb)->>'waistPrice')
  ) AS v(hair_add_type_code, add_amount_raw)
  WHERE fn_safe_boolean((m.data::jsonb)->>'isAddPrice')
    AND v.add_amount_raw IS NOT NULL
    AND v.add_amount_raw <> ''
  ON CONFLICT (designer_treatment_add_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_desinger_treatment_add');
END;
$$;
