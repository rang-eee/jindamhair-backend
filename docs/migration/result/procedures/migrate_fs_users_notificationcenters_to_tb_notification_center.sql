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
