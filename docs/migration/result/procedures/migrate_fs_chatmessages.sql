-- migrate_fs_chatmessages.sql
-- Firestore fs_chatrooms__chatmessages -> tb_chatroom_message 이관 프로시저 (업무 통합)

CREATE OR REPLACE PROCEDURE migrate_fs_chatmessages_to_tb_chatroom_message()
LANGUAGE plpgsql
AS $$
BEGIN
  EXECUTE 'alter sequence if exists jindamhair.seq_tb_chatroom_message_chat_message_id restart with 1';
  TRUNCATE TABLE jindamhair.tb_chatroom_message RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_chatroom_message (
    chat_message_id,
    chatroom_id,
    write_uid,
    chat_message_type_code,
    chat_message_content_type_code,
    chat_message_content,
    delete_member_uid_arr,
    appointment_id,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_chatroom_message_chat_message_id')::text,
    COALESCE(c.chatroom_id, parent_doc_id),
    COALESCE(u.uid, data->>'authorId'),
    CASE
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.text', 'text', 'txt', '텍스트') THEN 'txt'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.image', 'image', '이미지') THEN 'image'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.video', 'video', '동영상') THEN 'video'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.file', 'file', '파일') THEN 'file'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.sound', 'sound', '음원') THEN 'sound'
      WHEN TRIM(COALESCE(data->>'messageType','')) IN ('MessageType.emoji', 'emoji', '이모티콘') THEN 'emoji'
      ELSE data->>'messageType'
    END,
    CASE
      WHEN TRIM(COALESCE(data->>'messageTextType','')) IN ('MessageTextType.basic', 'basic', '기본') THEN 'basic'
      WHEN TRIM(COALESCE(data->>'messageTextType','')) IN ('MessageTextType.review', 'review', '후기') THEN 'review'
      WHEN TRIM(COALESCE(data->>'messageTextType','')) = '' THEN 'basic'
      ELSE data->>'messageTextType'
    END,
    data->>'message',
    CASE
      WHEN jsonb_typeof(data->'deleteMemberIds') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'deleteMemberIds'))
      ELSE NULL
    END,
    COALESCE(a.appointment_id, data->>'appointmentId'),
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_chatrooms__chatmessages m
  LEFT JOIN jindamhair.tb_chatroom c
    ON c.migration_id = m.parent_doc_id
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = m.data->>'authorId'
  LEFT JOIN jindamhair.tb_appointment a
    ON a.migration_id = m.data->>'appointmentId'
  WHERE COALESCE(fn_safe_timestamp(m.data->>'createAt'), m.created_at) >= TIMESTAMP '2026-01-01 00:00:00'
    AND COALESCE(fn_safe_timestamp(m.data->>'createAt'), m.created_at) < TIMESTAMP '2027-01-01 00:00:00'
  ON CONFLICT (chat_message_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom_message');
  PERFORM jindamhair.normalize_blank_array_to_null('jindamhair', 'tb_chatroom_message');
END;
$$;
