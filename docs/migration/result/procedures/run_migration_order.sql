-- run_migration_order.sql
-- 마이그레이션 실행 순서 (의존성 기준)
-- 사전 준비: common_functions.sql → all_procedures.sql 순으로 실행
-- 주의: 프로시저 내부에서 TRUNCATE 수행 (스테이징에서 검증 후 운영 적용 권장)
-- 실행 권장: 섹션 단위로 커밋하며 확인

-- 선택: 시퀀스 초기화 (필요 시에만)
--SELECT jindamhair.reset_migration_sequences_to_1();

TRUNCATE TABLE jindamhair.tb_file RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_configuration RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_user RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_user_bookmark RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_desinger_treatment RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_desinger_treatment_add RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_treatment RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_treatment_class RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_deeplink RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_shop RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_designer_shop RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_appointment RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_appointment_treatment RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_chatroom RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_chatroom_member RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_chatroom_message RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_user_push RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_admin_notification RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_notification RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_notification_center RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_banner RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_offer RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_offer_treatment RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_offer_designer RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_review RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_designer_review RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_payment RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_recommand RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_appointment_sign RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_appointment_sign_line RESTART IDENTITY CASCADE;
TRUNCATE TABLE jindamhair.tb_appointment_sign_point RESTART IDENTITY CASCADE;

-- 마스터/기초 (참조 테이블 선행)
CALL migrate_fs_configuration_to_tb_configuration();
CALL migrate_fs_treatmentclassfications_to_tb_treatment_class();
CALL migrate_fs_treatments_to_tb_treatment();
CALL migrate_fs_stores_to_tb_shop();
CALL migrate_fs_dynamiclinks_to_tb_deeplink();

-- 사용자/디자이너 (파일/유저 선행)
CALL migrate_fs_users_to_tb_user();
CALL migrate_fs_users_menus_to_tb_desinger_treatment();
CALL migrate_fs_users_menus_to_tb_desinger_treatment_add();
CALL migrate_fs_users_to_tb_designer_shop();
CALL migrate_fs_users_to_tb_designer_review();
CALL migrate_fs_users_to_tb_user_bookmark();

-- 예약/시술 (appointments → reservations 순)
CALL migrate_fs_appointments_to_tb_appointment();
--CALL migrate_fs_reservations_to_tb_appointment();
CALL migrate_fs_appointments_menus_to_tb_appointment_treatment();
--CALL migrate_fs_reservations_menus_to_tb_appointment_treatment();
CALL migrate_fs_appointments_sign_to_tb_appointment_sign();

-- 후기/추천
CALL migrate_fs_reviews_to_tb_review();
CALL migrate_fs_statistics_to_tb_recommand();

-- 오퍼 (통합 프로시저 내부에서 offer/designer/treatment 처리)
CALL migrate_fs_offers_to_tb_offer();

-- 알림/푸시 (유저 이후 실행)
CALL migrate_fs_alerts_to_tb_admin_notification();
CALL migrate_fs_notifications_to_tb_notification();
CALL migrate_fs_users_notificationcenters_to_tb_notification_center();
CALL migrate_fs_pushes_to_tb_user_push();

-- 채팅 (채팅방 → 멤버 → 메시지)
CALL migrate_fs_chatrooms_to_tb_chatroom();
CALL migrate_fs_chatrooms_to_tb_chatroom_member();
CALL migrate_fs_chatmessages_to_tb_chatroom_message();

-- 배너/결제
CALL migrate_fs_banners_to_tb_banner();
CALL migrate_fs_payments_to_tb_payment();
