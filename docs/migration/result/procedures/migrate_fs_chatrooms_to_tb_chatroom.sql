-- migrate_fs_chatrooms_to_tb_chatroom.sql
-- Firestore fs_chatrooms -> tb_chatroom 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_chatrooms_to_tb_chatroom()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_chatroom RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_chatroom (
    chatroom_id,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
      nextval('seq_tb_chatroom_chatroom_id')::text,
    doc_id,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_chatrooms
  ON CONFLICT (chatroom_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_chatroom');
END;
$$;
