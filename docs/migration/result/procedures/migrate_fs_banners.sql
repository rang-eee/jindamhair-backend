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
