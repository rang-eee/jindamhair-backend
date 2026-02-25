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
