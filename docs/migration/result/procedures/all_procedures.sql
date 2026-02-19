-- all_procedures.sql
-- 공통 함수 + 전체 프로시저 모음 (복붙 실행용)

-- common_functions.sql
-- 공통 함수 정의 (Migration 공용)
-- 필요 시 선택적으로 실행

-- 문자열 Timestamp를 안전하게 timestamp로 변환
CREATE OR REPLACE FUNCTION fn_safe_timestamp(val text)
RETURNS timestamp AS $$
BEGIN
  IF val IS NULL OR trim(val) = '' THEN
    RETURN NULL;
  END IF;
  RETURN val::timestamp;
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



-- =====================================================
-- migrate_fs_alerts_to_tb_admin_notification.sql
-- =====================================================
-- migrate_fs_alerts_to_tb_admin_notification.sql
-- Firestore fs_alerts -> tb_admin_notification 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_alerts_to_tb_admin_notification()
LANGUAGE plpgsql
AS $$
BEGIN
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
    data->>'sendUserType',
    data->>'targetUserType',
    data->>'sendMethodType',
    data->>'sendPeriodType',
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

-- =====================================================
-- migrate_fs_appointments_menus_to_tb_appointment_treatment.sql
-- =====================================================
-- migrate_fs_appointments_menus_to_tb_appointment_treatment.sql
-- Firestore fs_appointments__menus -> tb_appointment_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_menus_to_tb_appointment_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
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
    treatment_photo_file_id,
    treatment_gender_type_code,
    discount_yn,
    add_yn,
    open_yn,
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
    COALESCE(dt.designer_treatment_id, m.data->>'designerId'),
    COALESCE(u.uid, a.data->>'userUid'),
    m.data->>'title',
    CASE WHEN (m.data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'price')::numeric ELSE NULL END,
    CASE WHEN (m.data->>'percent') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'percent')::numeric ELSE NULL END,
    CASE WHEN (m.data->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'salePrice')::numeric ELSE NULL END,
    m.data->>'hairAddType',
    NULL,
    CASE WHEN (m.data->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'totalPrice')::numeric ELSE NULL END,
    NULL,
    CASE WHEN (m.data->>'hairTime') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'hairTime')::numeric ELSE NULL END,
    CASE
      WHEN jsonb_typeof(m.data->'hairImageUrl') = 'array' THEN m.data->'hairImageUrl'->>0
      ELSE NULL
    END,
    m.data->>'hairGenderType',
    CASE WHEN fn_safe_boolean(m.data->>'isSalePrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(m.data->>'isAddPrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(m.data->>'isOpenMenu') THEN 'Y' ELSE 'N' END,
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
  LEFT JOIN jindamhair.tb_desinger_treatment dt
    ON dt.migration_id = m.data->>'designerId'
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = a.data->>'userUid'
  ON CONFLICT (appointment_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_treatment');
END;
$$;

-- =====================================================
-- migrate_fs_appointments_sign_to_tb_appointment_sign.sql
-- =====================================================
-- migrate_fs_appointments_sign_to_tb_appointment_sign.sql
-- Firestore fs_appointments__sign -> tb_appointment_sign 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_sign_to_tb_appointment_sign()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_appointment_sign RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_appointment_sign (
    appointment_sign_id,
    appointment_id,
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
    nextval('seq_tb_appointment_sign_appointment_sign_id')::text,
    COALESCE(a.appointment_id, parent_doc_id),
    data->>'signOffsetX',
    data->>'signOffsetY',
    data->>'signSize',
    data->>'signColor',
    CASE WHEN (data->>'sortOrder') ~ '^[0-9]+$' THEN (data->>'sortOrder')::numeric ELSE NULL END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_appointments__sign s
  LEFT JOIN jindamhair.tb_appointment a
    ON a.migration_id = s.parent_doc_id
  ON CONFLICT (appointment_sign_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_sign');
END;
$$;

-- =====================================================
-- migrate_fs_appointments_to_tb_appointment.sql
-- =====================================================
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
    COALESCE(ds.designer_shop_id,
      CASE
        WHEN COALESCE(data->>'designerUid','') <> '' AND COALESCE(data->>'storeId','') <> ''
          THEN (data->>'designerUid') || '_' || (data->>'storeId')
        ELSE NULL
      END
    ),
    LEFT(data->>'appointmentStatusType', 200),
    LEFT(data->>'beginMethodType', 200),
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    NULL,
    fn_safe_timestamp(data->>'startAt'),
    fn_safe_timestamp(data->>'endAt'),
    LEFT(data->>'paymentMethodType', 200),
    data->>'hairTitle',
    data->>'cancelReason',
    COALESCE(r.review_id, data->>'reviewId'),
    data->>'userName',
    data->>'userName',
    data->>'userPhoneNum',
    data->>'designerName',
    NULL,
    data->'designerModel'->>'phoneNum',
    data->>'storeName',
    data->'designerModel'->>'storeAddress',
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
    ON ds.migration_id = CASE
      WHEN COALESCE(a.data->>'designerUid','') <> '' AND COALESCE(a.data->>'storeId','') <> ''
        THEN (a.data->>'designerUid') || '_' || (a.data->>'storeId')
      ELSE NULL
    END
  LEFT JOIN jindamhair.tb_review r
    ON r.migration_id = a.data->>'reviewId'
  ON CONFLICT (appointment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment');
END;
$$;

-- =====================================================
-- migrate_fs_banners_to_tb_banner.sql
-- =====================================================
-- migrate_fs_banners_to_tb_banner.sql
-- Firestore fs_banners -> tb_banner 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_banners_to_tb_banner()
LANGUAGE plpgsql
AS $$
BEGIN
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
    data->>'bannerType',
    data->>'displayPositionType',
    data->>'displayTargetUserType',
    data->>'displayType',
    data->>'displayTimeType',
    data->>'iconType',
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

-- =====================================================
-- migrate_fs_chatmessages_to_tb_chatroom_message.sql
-- =====================================================
-- migrate_fs_chatmessages_to_tb_chatroom_message.sql
-- Firestore fs_chatrooms__chatmessages -> tb_chatroom_message 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_chatmessages_to_tb_chatroom_message()
LANGUAGE plpgsql
AS $$
BEGIN
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
    data->>'messageType',
    data->>'messageTextType',
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
  ON CONFLICT (chat_message_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom_message');
END;
$$;

-- =====================================================
-- migrate_fs_chatrooms_to_tb_chatroom_member.sql
-- =====================================================
-- migrate_fs_chatrooms_to_tb_chatroom_member.sql
-- Firestore fs_chatrooms -> tb_chatroom_member 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_chatrooms_to_tb_chatroom_member()
LANGUAGE plpgsql
AS $$
BEGIN
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
      updated_at
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
    COALESCE(created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM normalized
  LEFT JOIN jindamhair.tb_chatroom c
    ON c.migration_id = normalized.chatroom_id
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = normalized.uid
  ON CONFLICT (chatroom_member_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom_member');
END;
$$;

-- =====================================================
-- migrate_fs_chatrooms_to_tb_chatroom.sql
-- =====================================================
-- migrate_fs_chatrooms_to_tb_chatroom.sql
-- Firestore fs_chatrooms -> tb_chatroom 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_chatrooms_to_tb_chatroom()
LANGUAGE plpgsql
AS $$
BEGIN
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
-- migrate_fs_configuration_to_tb_configuration.sql
-- =====================================================
-- migrate_fs_configuration_to_tb_configuration.sql
-- Firestore fs_configuration -> tb_configuration 이관 프로시저

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

-- =====================================================
-- migrate_fs_dynamiclinks_to_tb_deeplink.sql
-- =====================================================
-- migrate_fs_dynamiclinks_to_tb_deeplink.sql
-- Firestore fs_dynamiclinks -> tb_deeplink 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_dynamiclinks_to_tb_deeplink()
LANGUAGE plpgsql
AS $$
BEGIN
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
    COALESCE((data->>'createAt')::timestamp, created_at, now()),
    'migration',
    COALESCE((data->>'updateAt')::timestamp, updated_at),
    'migration',
    'N'
  FROM fs_dynamiclinks
  ON CONFLICT (deeplink_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_deeplink');
END;
$$;

-- =====================================================
-- migrate_fs_notifications_to_tb_notification.sql
-- =====================================================
-- migrate_fs_notifications_to_tb_notification.sql
-- Firestore fs_notifications -> tb_notification 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_notifications_to_tb_notification()
LANGUAGE plpgsql
AS $$
BEGIN
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
-- migrate_fs_offers_designers_to_tb_offer_designer.sql
-- =====================================================
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

-- =====================================================
-- migrate_fs_offers_to_tb_offer_treatment.sql
-- =====================================================
-- migrate_fs_offers_to_tb_offer_treatment.sql
-- Firestore fs_offers -> tb_offer_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_offers_to_tb_offer_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_offer_treatment RESTART IDENTITY CASCADE;

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
    COALESCE(o.offer_id, all_lv.offer_id),
    treatment_level,
    treatment_code,
    all_lv.offer_id || '_' || treatment_level::text || '_' || treatment_code,
    now(),
    'migration',
    NULL,
    'migration',
    'N'
  FROM all_lv
  LEFT JOIN jindamhair.tb_offer o
    ON o.migration_id = all_lv.offer_id
  WHERE COALESCE(all_lv.offer_id,'') <> '' AND COALESCE(treatment_code,'') <> ''
  ON CONFLICT (offer_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_offer_treatment');
END;
$$;

-- =====================================================
-- migrate_fs_offers_to_tb_offer.sql
-- =====================================================
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
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_offer_offer_id')::text,
    data->>'offerStatusType',
    COALESCE(u.uid, data->>'offerUid'),
    fn_safe_timestamp(data->>'offerAt'),
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    data->>'offerLocationAddress',
    CASE WHEN (data->>'offerLocationDistance') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationDistance')::numeric ELSE NULL END,
    CASE WHEN (data->>'offerLocationLatitude') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationLatitude')::numeric ELSE NULL END,
    CASE WHEN (data->>'offerLocationLongitude') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationLongitude')::numeric ELSE NULL END,
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
END;
$$;

-- =====================================================
-- migrate_fs_payments_to_tb_payment.sql
-- =====================================================
-- migrate_fs_payments_to_tb_payment.sql
-- Firestore fs_payments -> tb_payment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_payments_to_tb_payment()
LANGUAGE plpgsql
AS $$
BEGIN
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

-- =====================================================
-- migrate_fs_pushes_to_tb_user_push.sql
-- =====================================================
-- migrate_fs_pushes_to_tb_user_push.sql
-- Firestore fs_pushes -> tb_user_push 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_pushes_to_tb_user_push()
LANGUAGE plpgsql
AS $$
BEGIN
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
    NULL,
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

-- =====================================================
-- migrate_fs_reservations_menus_to_tb_appointment_treatment.sql
-- =====================================================
-- migrate_fs_reservations_menus_to_tb_appointment_treatment.sql
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
    treatment_photo_file_id,
    treatment_gender_type_code,
    discount_yn,
    add_yn,
    open_yn,
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
    COALESCE(dt.designer_treatment_id, m.data->>'designerId'),
    COALESCE(u.uid, r.data->>'userUid'),
    m.data->>'title',
    CASE WHEN (m.data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'price')::numeric ELSE NULL END,
    CASE WHEN (m.data->>'percent') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'percent')::numeric ELSE NULL END,
    CASE WHEN (m.data->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'salePrice')::numeric ELSE NULL END,
    m.data->>'hairAddType',
    NULL,
    CASE WHEN (m.data->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'totalPrice')::numeric ELSE NULL END,
    NULL,
    CASE WHEN (m.data->>'hairTime') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (m.data->>'hairTime')::numeric ELSE NULL END,
    CASE
      WHEN jsonb_typeof(m.data->'hairImageUrl') = 'array' THEN m.data->'hairImageUrl'->>0
      ELSE NULL
    END,
    m.data->>'hairGenderType',
    CASE WHEN fn_safe_boolean(m.data->>'isSalePrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(m.data->>'isAddPrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(m.data->>'isOpenMenu') THEN 'Y' ELSE 'N' END,
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
  LEFT JOIN jindamhair.tb_desinger_treatment dt
    ON dt.migration_id = m.data->>'designerId'
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = r.data->>'userUid'
  ON CONFLICT (appointment_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment_treatment');
END;
$$;

-- =====================================================
-- migrate_fs_reservations_to_tb_appointment.sql
-- =====================================================
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
    COALESCE(ds.designer_shop_id,
      CASE
        WHEN COALESCE(data->>'designerUid','') <> ''
          AND COALESCE(data->>'storeId', data->'designerModel'->>'storeId','') <> ''
          THEN (data->>'designerUid') || '_' || COALESCE(data->>'storeId', data->'designerModel'->>'storeId')
        ELSE NULL
      END
    ),
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
    ON ds.migration_id = CASE
      WHEN COALESCE(r.data->>'designerUid','') <> ''
        AND COALESCE(r.data->>'storeId', r.data->'designerModel'->>'storeId','') <> ''
        THEN (r.data->>'designerUid') || '_' || COALESCE(r.data->>'storeId', r.data->'designerModel'->>'storeId')
      ELSE NULL
    END
  ON CONFLICT (appointment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_appointment');
END;
$$;

-- =====================================================
-- migrate_fs_reviews_to_tb_review.sql
-- =====================================================
-- migrate_fs_reviews_to_tb_review.sql
-- Firestore fs_reviews -> tb_review 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_reviews_to_tb_review()
LANGUAGE plpgsql
AS $$
BEGIN
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
        ARRAY(SELECT jsonb_array_elements_text(data->'reviewType'))
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
END;
$$;

-- =====================================================
-- migrate_fs_statistics_to_tb_recommand.sql
-- =====================================================
-- migrate_fs_statistics_to_tb_recommand.sql
-- Firestore fs_statistics -> tb_recommand 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_statistics_to_tb_recommand()
LANGUAGE plpgsql
AS $$
BEGIN
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
END;
$$;

-- =====================================================
-- migrate_fs_stores_to_tb_shop.sql
-- =====================================================
-- migrate_fs_stores_to_tb_shop.sql
-- Firestore fs_stores -> tb_shop 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_stores_to_tb_shop()
LANGUAGE plpgsql
AS $$
BEGIN
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

-- =====================================================
-- migrate_fs_treatmentclassfications_to_tb_treatment_class.sql
-- =====================================================
-- migrate_fs_treatmentclassfications_to_tb_treatment_class.sql
-- Firestore fs_treatmentclassfications -> tb_treatment_class 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_treatmentclassfications_to_tb_treatment_class()
LANGUAGE plpgsql
AS $$
BEGIN
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

-- =====================================================
-- migrate_fs_treatments_to_tb_treatment.sql
-- =====================================================
-- migrate_fs_treatments_to_tb_treatment.sql
-- Firestore fs_treatments -> tb_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_treatments_to_tb_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
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

-- =====================================================
-- migrate_fs_users_menus_to_tb_desinger_treatment_add.sql
-- =====================================================
-- migrate_fs_users_menus_to_tb_desinger_treatment_add.sql
-- Firestore fs_users__menus -> tb_desinger_treatment_add 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_menus_to_tb_desinger_treatment_add()
LANGUAGE plpgsql
AS $$
BEGIN
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
    (m.data::jsonb)->>'hairAddType',
    NULL,
    COALESCE((m.data::jsonb)->>'id', m.doc_id),
    COALESCE(fn_safe_timestamp((m.data::jsonb)->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus m
  LEFT JOIN jindamhair.tb_desinger_treatment dt
    ON dt.migration_id = COALESCE(m.data->>'id', m.doc_id)
  WHERE (m.data::jsonb)->>'hairAddType' IS NOT NULL AND (m.data::jsonb)->>'hairAddType' <> ''
  ON CONFLICT (designer_treatment_add_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_desinger_treatment_add');
END;
$$;

-- =====================================================
-- migrate_fs_users_menus_to_tb_desinger_treatment.sql
-- =====================================================
-- migrate_fs_users_menus_to_tb_desinger_treatment.sql
-- Firestore fs_users__menus -> tb_desinger_treatment 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_menus_to_tb_desinger_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_desinger_treatment RESTART IDENTITY CASCADE;

  -- 파일 URL 선적재 (중복 방지)
  INSERT INTO jindamhair.tb_file (
    file_id, sort_order, file_type_code, org_file_name, convert_file_name,
    file_path, file_size, migration_id, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
  )
  SELECT
    nextval('seq_tb_file_file_id')::text,
    1,
    'FLTP001',
    NULL,
    NULL,
    src.url,
    NULL,
    src.url,
    now(),
    'migration',
    NULL,
    NULL,
    'N',
    NULL,
    NULL
  FROM (
    SELECT DISTINCT m.data->'hairImageUrl'->>0 AS url
    FROM fs_users__menus m
  ) src
  WHERE src.url IS NOT NULL AND src.url <> ''
    AND NOT EXISTS (
      SELECT 1 FROM jindamhair.tb_file f WHERE f.file_path = src.url
    );

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
    data->>'title',
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    CASE WHEN (data->>'percent') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'percent')::numeric ELSE NULL END,
    CASE WHEN (data->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'salePrice')::numeric ELSE NULL END,
    CASE WHEN (data->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'totalPrice')::numeric ELSE NULL END,
    NULL,
    CASE WHEN (data->>'hairTime') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'hairTime')::numeric ELSE NULL END,
    CASE
      WHEN jsonb_typeof(data->'hairImageUrl') = 'array' THEN tf.file_id
      ELSE NULL
    END,
    data->>'hairGenderType',
    CASE WHEN fn_safe_boolean(data->>'isSalePrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(data->>'isAddPrice') THEN 'Y' ELSE 'N' END,
    CASE WHEN fn_safe_boolean(data->>'isOpenMenu') THEN 'Y' ELSE 'N' END,
    CASE WHEN (data->>'order') ~ '^[0-9]+$' THEN (data->>'order')::numeric ELSE NULL END,
    data->>'levelCode1',
    data->>'levelTitle1',
    data->>'levelCode2',
    data->>'levelTitle2',
    data->>'levelCode3',
    data->>'levelTitle3',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus m
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = m.parent_doc_id
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = m.data->'hairImageUrl'->>0 AND f.file_path <> ''
    ORDER BY f.file_id::bigint
    LIMIT 1
  ) tf ON true
  ON CONFLICT (designer_treatment_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_desinger_treatment');
END;
$$;

-- =====================================================
-- migrate_fs_users_notificationcenters_to_tb_notification_center.sql
-- =====================================================
-- migrate_fs_users_notificationcenters_to_tb_notification_center.sql
-- Firestore fs_users__notificationcenters -> tb_notification_center 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_notificationcenters_to_tb_notification_center()
LANGUAGE plpgsql
AS $$
BEGIN
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
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_notification_center_notification_center_id')::text,
    LEFT(data->>'notificationType', 200),
    data->>'eventWhenClick',
    LEFT(data->>'notificationType', 200),
    COALESCE(data->>'title', data->>'hairTitle'),
    data->>'message',
    COALESCE(u.uid, COALESCE(data->>'receiverUid', parent_doc_id)),
    COALESCE(a.appointment_id, data->>'appointmentId'),
    fn_safe_timestamp(data->'appointmentModel'->>'startAt'),
    COALESCE(data->>'desingerName', data->'appointmentModel'->>'designerName'),
    data->'appointmentModel'->>'userName',
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

-- =====================================================
-- migrate_fs_users_to_tb_designer_off.sql
-- =====================================================
-- migrate_fs_users_to_tb_designer_off.sql
-- Firestore fs_users -> tb_designer_off 이관 프로시저 (designerAllCloseTime 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_off()
LANGUAGE plpgsql
AS $$
BEGIN
  -- tb_designer_off 테이블 제거 요구사항 반영: tb_user.designer_off_date_arr로 이관
  -- 본 프로시저는 더 이상 사용하지 않음
  RETURN;
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_designer_review.sql
-- =====================================================
-- migrate_fs_users_to_tb_designer_review.sql
-- Firestore fs_users -> tb_designer_review 이관 프로시저 (users.reviewCount Map 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_review()
LANGUAGE plpgsql
AS $$
BEGIN
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
    review_type_code,
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
-- migrate_fs_users_to_tb_designer_shop.sql
-- =====================================================
-- migrate_fs_users_to_tb_designer_shop.sql
-- Firestore fs_users -> tb_designer_shop 이관 프로시저 (users.stores 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_shop()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_designer_shop RESTART IDENTITY CASCADE;

  WITH base AS (
    SELECT doc_id, data, created_at, updated_at
    FROM fs_users
  ),
  primary_shop AS (
    SELECT
      COALESCE(data->>'uid', data->>'id', doc_id) AS uid,
      data->>'storeId' AS shop_id,
      data->>'storeName' AS shop_name,
      data->>'storeAddress' AS shop_addr,
      NULL::text AS shop_addr_detail,
      data->>'storePhoneNum' AS shop_contact,
      NULL::text AS position_lngt,
      NULL::text AS position_latt,
      NULL::text AS zipcode,
      'Y'::bpchar AS representative_yn,
      NULL::text AS shop_regist_type_code,
      'Y'::bpchar AS use_yn,
      created_at,
      updated_at
    FROM base
    WHERE COALESCE(data->>'storeId','') <> ''
  ),
  extra_shops AS (
    SELECT
      COALESCE(b.data->>'uid', b.data->>'id', b.doc_id) AS uid,
      COALESCE(s.value->>'id', s.value->>'storeId') AS shop_id,
      COALESCE(s.value->>'title', s.value->>'name', s.value->>'storeName') AS shop_name,
      COALESCE(s.value->>'address', s.value->>'storeAddress') AS shop_addr,
      s.value->>'addressDetail' AS shop_addr_detail,
      COALESCE(s.value->>'contactNumber', s.value->>'phoneNum', s.value->>'storePhoneNum') AS shop_contact,
      s.value->>'gpsX' AS position_lngt,
      s.value->>'gpsY' AS position_latt,
      s.value->>'postCode' AS zipcode,
      CASE WHEN fn_safe_boolean(s.value->>'isRepresentative') THEN 'Y' ELSE 'N' END AS representative_yn,
      s.value->>'storeAddType' AS shop_regist_type_code,
      'Y'::bpchar AS use_yn,
      b.created_at,
      b.updated_at
    FROM base b
    JOIN LATERAL jsonb_array_elements(b.data->'stores') AS s(value)
      ON jsonb_typeof(b.data->'stores') = 'array'
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
    COALESCE(s.shop_id, combined.shop_id),
    shop_regist_type_code,
    representative_yn,
    combined.shop_name,
    NULL,
    combined.shop_addr,
    combined.shop_addr_detail,
    combined.shop_contact,
    combined.position_lngt,
    combined.position_latt,
    combined.zipcode,
    combined.use_yn,
    combined.uid || '_' || combined.shop_id,
    COALESCE(created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM combined
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = combined.uid
  LEFT JOIN jindamhair.tb_shop s
    ON s.migration_id = combined.shop_id
  WHERE COALESCE(combined.uid,'') <> ''
    AND COALESCE(combined.shop_id,'') <> ''
  ON CONFLICT (designer_shop_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_designer_shop');
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_user_bookmark.sql
-- =====================================================
-- migrate_fs_users_to_tb_user_bookmark.sql
-- Firestore fs_users -> tb_user_bookmark 이관 프로시저 (favoriteIds 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_user_bookmark()
LANGUAGE plpgsql
AS $$
BEGIN
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
    COALESCE(base.data->>'genderType', fav.data->>'genderType') AS user_gender_code,
    COALESCE(base.data->>'ageType', fav.data->>'ageType') AS user_agg_code,
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
-- migrate_fs_users_to_tb_user.sql
-- =====================================================
-- migrate_fs_users_to_tb_user.sql
-- Firestore fs_users -> tb_user 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_user()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_user RESTART IDENTITY CASCADE;

  -- 파일 URL 선적재 (중복 방지)
  INSERT INTO jindamhair.tb_file (
    file_id, sort_order, file_type_code, org_file_name, convert_file_name,
    file_path, file_size, migration_id, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
  )
  SELECT
    nextval('seq_tb_file_file_id')::text,
    1,
    'FLTP001',
    NULL,
    NULL,
    src.url,
    NULL,
    src.url,
    now(),
    'migration',
    NULL,
    NULL,
    'N',
    NULL,
    NULL
  FROM (
    SELECT DISTINCT url
    FROM (
      SELECT u.data->>'imageUrl' AS url
      FROM fs_users u
      UNION ALL
      SELECT u.data->>'designerLicenseImageUrl' AS url
      FROM fs_users u
      UNION ALL
      SELECT u.data->'designerPhotos'->>0 AS url
      FROM fs_users u
    ) s
  ) src
  WHERE src.url IS NOT NULL AND src.url <> ''
    AND NOT EXISTS (
      SELECT 1 FROM jindamhair.tb_file f WHERE f.file_path = src.url
    );

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
    LEFT(data->>'userStatusType', 200),
    LEFT(data->>'userType', 200),
    data->>'birth',
    LEFT(
      regexp_replace(
        BTRIM(COALESCE(data->>'signUpMethodType', data->>'signUpMethod')),
        '^SignUpMethod\.',
        'SignUpMethodType.'
      ),
      200
    ),
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
    pf.file_id,
    LEFT(data->>'designerAuthStatusType', 200),
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
    CASE WHEN fn_safe_boolean(data->>'designerIsWork') THEN 'Y' ELSE 'N' END,
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
    df.file_id,
    LEFT(data->>'designerAccountBrandType', 200),
    COALESCE(data->>'uid', data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_users u
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = u.data->>'imageUrl' AND f.file_path <> ''
    ORDER BY f.file_id::bigint
    LIMIT 1
  ) pf ON true
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = u.data->>'designerLicenseImageUrl' AND f.file_path <> ''
    ORDER BY f.file_id::bigint
    LIMIT 1
  ) lf ON true
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = u.data->'designerPhotos'->>0 AND f.file_path <> ''
    ORDER BY f.file_id::bigint
    LIMIT 1
  ) df ON true
  ON CONFLICT (uid) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_user');
  PERFORM jindamhair.normalize_blank_array_to_null('jindamhair', 'tb_user');
END;
$$;
