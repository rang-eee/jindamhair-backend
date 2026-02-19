-- run_migration_order.sql
-- 마이그레이션 실행 순서 (의존성 기준)
-- 필요 시 먼저 common_functions.sql / all_procedures.sql 실행

-- 선택: 시퀀스 초기화
SELECT jindamhair.reset_migration_sequences_to_1();

-- 마스터/기초
CALL migrate_fs_configuration_to_tb_configuration();
CALL migrate_fs_treatmentclassfications_to_tb_treatment_class();
CALL migrate_fs_treatments_to_tb_treatment();
CALL migrate_fs_stores_to_tb_shop();
CALL migrate_fs_dynamiclinks_to_tb_deeplink();

-- 사용자/디자이너
CALL migrate_fs_users_to_tb_user();
CALL migrate_fs_users_menus_to_tb_desinger_treatment();
CALL migrate_fs_users_menus_to_tb_desinger_treatment_add();
CALL migrate_fs_users_to_tb_designer_shop();
CALL migrate_fs_users_to_tb_designer_review();
CALL migrate_fs_users_to_tb_user_bookmark();

-- 예약/시술 (appointments -> reservations 순)
CALL migrate_fs_appointments_to_tb_appointment();
CALL migrate_fs_reservations_to_tb_appointment();
CALL migrate_fs_appointments_menus_to_tb_appointment_treatment();
CALL migrate_fs_reservations_menus_to_tb_appointment_treatment();
CALL migrate_fs_appointments_sign_to_tb_appointment_sign();

-- 후기/추천
CALL migrate_fs_reviews_to_tb_review();
CALL migrate_fs_statistics_to_tb_recommand();

-- 오퍼
CALL migrate_fs_offers_to_tb_offer();
CALL migrate_fs_offers_to_tb_offer_treatment();
CALL migrate_fs_offers_designers_to_tb_offer_designer();

-- 알림/푸시
CALL migrate_fs_alerts_to_tb_admin_notification();
CALL migrate_fs_notifications_to_tb_notification();
CALL migrate_fs_users_notificationcenters_to_tb_notification_center();
CALL migrate_fs_pushes_to_tb_user_push();

-- 채팅
CALL migrate_fs_chatrooms_to_tb_chatroom();
CALL migrate_fs_chatrooms_to_tb_chatroom_member();
CALL migrate_fs_chatmessages_to_tb_chatroom_message();

-- 배너/결제
CALL migrate_fs_banners_to_tb_banner();
CALL migrate_fs_payments_to_tb_payment();
