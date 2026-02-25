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
