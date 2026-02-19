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
