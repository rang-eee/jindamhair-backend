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
