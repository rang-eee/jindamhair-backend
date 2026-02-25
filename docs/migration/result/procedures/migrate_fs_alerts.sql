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
