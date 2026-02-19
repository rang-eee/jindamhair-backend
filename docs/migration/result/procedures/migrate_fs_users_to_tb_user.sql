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
