-- all_procedures.sql
-- 공통 함수 + 전체 프로시저 모음 (복붙 실행용)

-- =====================================================
-- common_functions.sql
-- =====================================================
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


-- =====================================================
-- migrate_fs_dynamiclinks_to_tb_deeplink.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'sendUserType',
    data->>'targetUserType',
    data->>'sendMethodType',
    data->>'sendPeriodType',
    data->>'title',
    data->>'message',
    fn_safe_timestamp(data->>'sendAt'),
    CASE WHEN fn_safe_boolean(data->>'successYn') THEN 'Y' ELSE 'N' END,
    NULL,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_alerts
  ON CONFLICT (admin_notification_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_statistics_to_tb_recommand.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'designerUid',
    NULLIF(data->>'designerRecommendCount', '')::numeric,
    CASE
      WHEN jsonb_typeof(data->'joinUserUids') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'joinUserUids'))
      ELSE NULL
    END,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_statistics
  ON CONFLICT (recommand_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_chatrooms_to_tb_chatroom.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_chatrooms_to_tb_chatroom()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_chatroom RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_chatroom (
    chatroom_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_chatrooms
  ON CONFLICT (chatroom_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_chatrooms_to_tb_chatroom_member.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT DISTINCT
    chatroom_id || '_' || uid AS chatroom_member_id,
    chatroom_id,
    uid,
    chatroom_name,
    last_read_at,
    COALESCE(created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM normalized
  ON CONFLICT (chatroom_member_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_chatmessages_to_tb_chatroom_message.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    parent_doc_id,
    data->>'authorId',
    data->>'messageType',
    data->>'messageTextType',
    data->>'message',
    CASE
      WHEN jsonb_typeof(data->'deleteMemberIds') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'deleteMemberIds'))
      ELSE NULL
    END,
    data->>'appointmentId',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_chatrooms__chatmessages
  ON CONFLICT (chat_message_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_dynamiclinks_to_tb_deeplink.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_user()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_user RESTART IDENTITY CASCADE;

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
    designer_license_photo_file_id,
    designer_appr_status_code,
    designer_introduce_content,
    designer_tag_arr,
    designer_work_status_code,
    designer_open_day_arr,
    designer_open_time_arr,
    designer_close_time_arr,
    designer_appointment_automatic_confirm_yn,
    designer_applink_url,
    designer_detail_photo_file_id,
    designer_account_brand_code,
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
    data->>'userStatusType',
    data->>'userType',
    data->>'birth',
    data->>'signUpMethodType',
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
    COALESCE(pf.file_id, pfi.file_id),
    COALESCE(lf.file_id, lfi.file_id),
    data->>'designerAuthStatusType',
    data->>'designerInfo',
    CASE
      WHEN jsonb_typeof(data->'designerTags') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'designerTags'))
      WHEN data ? 'designerTags' THEN
        ARRAY[ data->>'designerTags' ]
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
    CASE WHEN fn_safe_boolean(data->>'designerAutoConfirmAppointment') THEN 'Y' ELSE 'N' END,
    data->>'designerDetailDynamicLinkUrl',
    COALESCE(df.file_id, dfi.file_id),
    data->>'designerAccountBrandType',
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
    LIMIT 1
  ) pf ON true
  LEFT JOIN LATERAL (
    INSERT INTO jindamhair.tb_file (
      file_id, sort_order, file_type_code, org_file_name, convert_file_name,
      file_path, file_size, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
    )
    SELECT nextval('seq_tb_file_file_id')::text, 1, 'FLTP001', NULL, NULL,
      u.data->>'imageUrl', NULL, now(), 'migration', NULL, NULL, 'N', NULL, NULL
    WHERE (u.data->>'imageUrl') IS NOT NULL AND (u.data->>'imageUrl') <> '' AND pf.file_id IS NULL
    RETURNING file_id
  ) pfi ON true
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = u.data->>'designerLicenseImageUrl' AND f.file_path <> ''
    LIMIT 1
  ) lf ON true
  LEFT JOIN LATERAL (
    INSERT INTO jindamhair.tb_file (
      file_id, sort_order, file_type_code, org_file_name, convert_file_name,
      file_path, file_size, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
    )
    SELECT nextval('seq_tb_file_file_id')::text, 1, 'FLTP001', NULL, NULL,
      u.data->>'designerLicenseImageUrl', NULL, now(), 'migration', NULL, NULL, 'N', NULL, NULL
    WHERE (u.data->>'designerLicenseImageUrl') IS NOT NULL AND (u.data->>'designerLicenseImageUrl') <> '' AND lf.file_id IS NULL
    RETURNING file_id
  ) lfi ON true
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = u.data->'designerPhotos'->>0 AND f.file_path <> ''
    LIMIT 1
  ) df ON true
  LEFT JOIN LATERAL (
    INSERT INTO jindamhair.tb_file (
      file_id, sort_order, file_type_code, org_file_name, convert_file_name,
      file_path, file_size, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
    )
    SELECT nextval('seq_tb_file_file_id')::text, 1, 'FLTP001', NULL, NULL,
      u.data->'designerPhotos'->>0, NULL, now(), 'migration', NULL, NULL, 'N', NULL, NULL
    WHERE (u.data->'designerPhotos'->>0) IS NOT NULL AND (u.data->'designerPhotos'->>0) <> '' AND df.file_id IS NULL
    RETURNING file_id
  ) dfi ON true
  ON CONFLICT (uid) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_user_bookmark.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_user_bookmark()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_user_bookmark RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_user_bookmark (
    user_bookmark_id,
    uid,
    bookmark_uid,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    owner_uid || '_' || bookmark_uid AS user_bookmark_id,
    owner_uid AS uid,
    bookmark_uid,
    COALESCE(fn_safe_timestamp(user_create_at), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM (
    SELECT
      COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) AS owner_uid,
      u.data->>'createAt' AS user_create_at,
      u.created_at,
      u.updated_at,
      fav_uid AS bookmark_uid
    FROM fs_users u
    JOIN LATERAL jsonb_array_elements_text(u.data->'favoriteIds') AS fav_uid
      ON jsonb_typeof(u.data->'favoriteIds') = 'array'
  ) t
  WHERE owner_uid IS NOT NULL AND owner_uid <> ''
    AND bookmark_uid IS NOT NULL AND bookmark_uid <> ''
  ON CONFLICT (user_bookmark_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_users_notificationcenters_to_tb_notification_center.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'notificationType',
    data->>'eventWhenClick',
    data->>'notificationType',
    COALESCE(data->>'title', data->>'hairTitle'),
    data->>'message',
    COALESCE(data->>'receiverUid', parent_doc_id),
    data->>'appointmentId',
    fn_safe_timestamp(data->'appointmentModel'->>'startAt'),
    COALESCE(data->>'desingerName', data->'appointmentModel'->>'designerName'),
    data->'appointmentModel'->>'userName',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__notificationcenters
  ON CONFLICT (notification_center_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_designer_off.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_off()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_designer_off RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_designer_off (
    off_id,
    uid,
    off_at,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    uid || '_' || off_at_text AS off_id,
    uid,
    fn_safe_timestamp(off_at_text) AS off_at,
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
      off_at_text
    FROM fs_users u
    JOIN LATERAL jsonb_array_elements_text(u.data->'designerAllCloseTime') AS off_at_text
      ON jsonb_typeof(u.data->'designerAllCloseTime') = 'array'
  ) t
  WHERE uid IS NOT NULL AND uid <> ''
    AND off_at_text IS NOT NULL AND off_at_text <> ''
  ON CONFLICT (off_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_users_menus_to_tb_desinger_treatment.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_users_menus_to_tb_desinger_treatment()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_desinger_treatment RESTART IDENTITY CASCADE;

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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    parent_doc_id,
    data->>'title',
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    CASE WHEN (data->>'percent') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'percent')::numeric ELSE NULL END,
    CASE WHEN (data->>'salePrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'salePrice')::numeric ELSE NULL END,
    CASE WHEN (data->>'totalPrice') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'totalPrice')::numeric ELSE NULL END,
    NULL,
    CASE WHEN (data->>'hairTime') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'hairTime')::numeric ELSE NULL END,
    CASE
      WHEN jsonb_typeof(data->'hairImageUrl') = 'array' THEN COALESCE(tf.file_id, tfi.file_id)
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
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus m
  LEFT JOIN LATERAL (
    SELECT f.file_id
    FROM jindamhair.tb_file f
    WHERE f.file_path = m.data->'hairImageUrl'->>0 AND f.file_path <> ''
    LIMIT 1
  ) tf ON true
  LEFT JOIN LATERAL (
    INSERT INTO jindamhair.tb_file (
      file_id, sort_order, file_type_code, org_file_name, convert_file_name,
      file_path, file_size, create_at, create_id, update_at, update_id, delete_yn, delete_at, delete_id
    )
    SELECT nextval('seq_tb_file_file_id')::text, 1, 'FLTP001', NULL, NULL,
      m.data->'hairImageUrl'->>0, NULL, now(), 'migration', NULL, NULL, 'N', NULL, NULL
    WHERE (m.data->'hairImageUrl'->>0) IS NOT NULL AND (m.data->'hairImageUrl'->>0) <> '' AND tf.file_id IS NULL
    RETURNING file_id
  ) tfi ON true
  ON CONFLICT (designer_treatment_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_users_menus_to_tb_desinger_treatment_add.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id) || '_' || (data->>'hairAddType') AS designer_treatment_add_id,
    COALESCE(data->>'id', doc_id) AS designer_treatment_id,
    data->>'hairAddType',
    NULL,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_users__menus
  WHERE data->>'hairAddType' IS NOT NULL AND data->>'hairAddType' <> ''
  ON CONFLICT (designer_treatment_add_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_designer_shop.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    uid || '_' || shop_id AS designer_shop_id,
    uid,
    shop_id,
    shop_regist_type_code,
    representative_yn,
    shop_name,
    NULL,
    shop_addr,
    shop_addr_detail,
    shop_contact,
    position_lngt,
    position_latt,
    zipcode,
    use_yn,
    COALESCE(created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM combined
  WHERE COALESCE(uid,'') <> ''
    AND COALESCE(shop_id,'') <> ''
  ON CONFLICT (designer_shop_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_users_to_tb_designer_review.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_review()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_designer_review RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_designer_review (
    designer_review_id,
    review_type_code,
    review_count,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    uid || '_' || review_type_code AS designer_review_id,
    review_type_code,
    review_count,
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
END;
$$;

-- =====================================================
-- migrate_fs_offers_to_tb_offer.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'offerStatusType',
    data->>'offerUid',
    fn_safe_timestamp(data->>'offerAt'),
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    data->>'offerLocationAddress',
    CASE WHEN (data->>'offerLocationDistance') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationDistance')::numeric ELSE NULL END,
    CASE WHEN (data->>'offerLocationLatitude') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationLatitude')::numeric ELSE NULL END,
    CASE WHEN (data->>'offerLocationLongitude') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'offerLocationLongitude')::numeric ELSE NULL END,
    data->>'offerMemo',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_offers
  ON CONFLICT (offer_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_offers_to_tb_offer_treatment.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    offer_id || '_' || treatment_level::text || '_' || treatment_code AS offer_treatment_id,
    offer_id,
    treatment_level,
    treatment_code,
    now(),
    'migration',
    NULL,
    'migration',
    'N'
  FROM all_lv
  WHERE COALESCE(offer_id,'') <> '' AND COALESCE(treatment_code,'') <> ''
  ON CONFLICT (offer_treatment_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_offers_designers_to_tb_offer_designer.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_offers_designers_to_tb_offer_designer()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_offer_designer RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_offer_designer (
    offer_designer_id,
    offer_id,
    offer_agree_status_code,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    parent_doc_id || '_' || doc_id AS offer_designer_id,
    parent_doc_id AS offer_id,
    data->>'status',
    COALESCE(fn_safe_timestamp(data->>'createAt'), now()),
    'migration',
    NULL,
    'migration',
    'N'
  FROM fs_offers__designers
  ON CONFLICT (offer_designer_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_appointments_to_tb_appointment.sql
-- =====================================================
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

-- =====================================================
-- migrate_fs_appointments_menus_to_tb_appointment_treatment.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(m.data->>'id', m.doc_id),
    m.data->>'designerId',
    a.data->>'userUid',
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
    COALESCE(fn_safe_timestamp(m.data->>'createAt'), m.created_at, now()),
    'migration',
    m.updated_at,
    'migration',
    'N'
  FROM fs_appointments__menus m
  LEFT JOIN fs_appointments a
    ON a.doc_id = m.parent_doc_id
  ON CONFLICT (appointment_treatment_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_appointments_sign_to_tb_appointment_sign.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    parent_doc_id,
    data->>'signOffsetX',
    data->>'signOffsetY',
    data->>'signSize',
    data->>'signColor',
    CASE WHEN (data->>'sortOrder') ~ '^[0-9]+$' THEN (data->>'sortOrder')::numeric ELSE NULL END,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_appointments__sign
  ON CONFLICT (appointment_sign_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_reservations_to_tb_appointment.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_reservations_to_tb_appointment()
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
      WHEN COALESCE(data->>'designerUid','') <> '' AND COALESCE(data->'designerModel'->>'storeId','') <> ''
        THEN (data->>'designerUid') || '_' || (data->'designerModel'->>'storeId')
      ELSE NULL
    END,
    data->>'reservationStatus',
    data->>'reservationType',
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    CASE WHEN (data->>'price') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'price')::numeric ELSE NULL END,
    fn_safe_timestamp(data->>'startAt'),
    fn_safe_timestamp(data->>'endAt'),
    data->>'paymentMethod',
    data->>'hairTitle',
    NULL,
    NULL,
    data->>'userName',
    data->>'userName',
    data->>'userPhoneNum',
    data->>'designerName',
    data->'designerModel'->>'nickname',
    data->'designerModel'->>'phoneNum',
    data->>'storeName',
    data->'designerModel'->>'storeAddress',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_reservations
  ON CONFLICT (appointment_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_reservations_menus_to_tb_appointment_treatment.sql
-- =====================================================
CREATE OR REPLACE PROCEDURE migrate_fs_reservations_menus_to_tb_appointment_treatment()
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(m.data->>'id', m.doc_id),
    m.data->>'designerId',
    r.data->>'userUid',
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
    COALESCE(fn_safe_timestamp(m.data->>'createAt'), m.created_at, now()),
    'migration',
    m.updated_at,
    'migration',
    'N'
  FROM fs_reservations__menus m
  LEFT JOIN fs_reservations r
    ON r.doc_id = m.parent_doc_id
  ON CONFLICT (appointment_treatment_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_dynamiclinks_to_tb_deeplink.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'linkKey',
    data->>'email',
    data->>'link',
    COALESCE((data->>'createAt')::timestamp, created_at, now()),
    'migration',
    COALESCE((data->>'updateAt')::timestamp, updated_at),
    'migration',
    'N'
  FROM fs_dynamiclinks
  ON CONFLICT (deeplink_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_banners_to_tb_banner.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
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
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_banners
  ON CONFLICT (banner_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_configuration_to_tb_configuration.sql
-- =====================================================
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
END;
$$;

-- =====================================================
-- migrate_fs_notifications_to_tb_notification.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'receiverUid',
    data->>'title',
    data->>'message',
    data->>'topic',
    data->>'eventWhenClick',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_notifications
  ON CONFLICT (notification_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_pushes_to_tb_user_push.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    NULL,
    data->>'receiveId',
    data->>'title',
    data->>'message',
    fn_safe_timestamp(data->>'sendAt'),
    CASE WHEN fn_safe_boolean(data->>'isSend') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'sendedAt'),
    NULL,
    data->>'eventWhenClick',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_pushes
  ON CONFLICT (user_push_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_payments_to_tb_payment.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'paymentType',
    data->>'paymentKey',
    CASE
      WHEN (data->>'orderId') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'orderId')::numeric
      ELSE NULL
    END,
    CASE
      WHEN (data->>'amount') ~ '^[0-9]+(\\.[0-9]+)?$' THEN (data->>'amount')::numeric
      ELSE NULL
    END,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_payments
  ON CONFLICT (payment_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_reviews_to_tb_review.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'appointmentId',
    CASE
      WHEN jsonb_typeof(data->'reviewType') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'reviewType'))
      ELSE NULL
    END,
    data->>'reviewContent',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_reviews
  ON CONFLICT (review_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_stores_to_tb_shop.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'title',
    data->>'description',
    data->>'address',
    data->>'addressDetail',
    COALESCE(data->>'contactNumber', data->>'phoneNum'),
    data->>'gpsX',
    data->>'gpsY',
    data->>'postCode',
    'Y',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_stores
  ON CONFLICT (shop_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_treatmentclassfications_to_tb_treatment_class.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
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
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_treatmentclassfications
  ON CONFLICT (treatment_class_id) DO NOTHING;
END;
$$;

-- =====================================================
-- migrate_fs_treatments_to_tb_treatment.sql
-- =====================================================
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
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'code',
    data->>'title',
    NULLIF(data->>'level', '')::numeric,
    NULLIF(data->>'sort', '')::numeric,
    NULLIF(data->>'offerMinPrice', '')::numeric,
    CASE WHEN fn_safe_boolean(data->>'useYn') THEN 'Y' ELSE 'N' END,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_treatments
  ON CONFLICT (treatment_id) DO NOTHING;
END;
$$;
