-- migrate_fs_users_to_tb_user_bookmark.sql
-- Firestore fs_users -> tb_user_bookmark 이관 프로시저 (favoriteIds 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_user_bookmark()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_user_bookmark RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_user_bookmark (
    user_bookmark_id,
    uid,
    bookmark_uid,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    owner_uid || '_' || bookmark_uid AS user_bookmark_id,
    owner_uid AS uid,
    bookmark_uid,
    COALESCE(fn_safe_timestamp(user_create_at), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM (
    SELECT
      COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) AS owner_uid,
      u.data->>'createAt' AS user_create_at,
      u.created_at,
      u.updated_at,
      fav_uid AS bookmark_uid
    FROM fs_users u
    JOIN LATERAL jsonb_array_elements_text(u.data->'favoriteIds') AS fav_uid
      ON jsonb_typeof(u.data->'favoriteIds') = 'array'
  ) t
  WHERE owner_uid IS NOT NULL AND owner_uid <> ''
    AND bookmark_uid IS NOT NULL AND bookmark_uid <> ''
  ON CONFLICT (user_bookmark_id) DO NOTHING;
END;
$$;
