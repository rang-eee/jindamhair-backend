-- migrate_fs_pushes.sql
-- Firestore fs_pushes -> tb_user_push 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_pushes_to_tb_user_push()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_user_push_user_push_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_user_push RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_user_push (
    user_push_id,
    sender_uid,
    receiver_uid,
    push_title,
    push_content,
    send_at,
    send_yn,
    send_complete_at,
    push_type_code,
    push_link_val,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_user_push_user_push_id')::text,
    CASE
      WHEN TRIM(COALESCE(data->>'pushType','')) IN ('PushType.chat', 'chat', '채팅', 'PSTP001') THEN 'chat'
      WHEN TRIM(COALESCE(data->>'pushType','')) IN ('PushType.appointment', 'appointment', '예약', 'PSTP002') THEN 'appointment'
      WHEN TRIM(COALESCE(data->>'pushType','')) IN ('PushType.recommand', 'PushType.recommend', 'recommand', 'recommend', '추천', 'PSTP003') THEN 'recommand'
      ELSE data->>'pushType'
    END,
    COALESCE(u.uid, data->>'receiveId'),
    data->>'title',
    data->>'message',
    fn_safe_timestamp(data->>'sendAt'),
    CASE WHEN fn_safe_boolean(data->>'isSend') THEN 'Y' ELSE 'N' END,
    fn_safe_timestamp(data->>'sendedAt'),
    NULL,
    data->>'eventWhenClick',
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_pushes p
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = p.data->>'receiveId'
  ON CONFLICT (user_push_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_user_push');
END;
$$;
