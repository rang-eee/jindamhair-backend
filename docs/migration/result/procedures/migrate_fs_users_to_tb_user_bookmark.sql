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
    bookmark_target_user_id,
    user_gender_code,
    user_agg_code,
    user_type_code,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  WITH base AS (
    SELECT
      COALESCE(data->>'uid', data->>'userId', data->>'ownerUid') AS owner_uid,
      COALESCE(data->>'favoriteId', data->>'favoriteUid', data->>'targetUid') AS bookmark_uid,
      data,
      created_at,
      updated_at
    FROM fs_usersfavorites
  )
  SELECT
    nextval('seq_tb_user_bookmark_user_bookmark_id')::text AS user_bookmark_id,
    COALESCE(target.uid, base.bookmark_uid) AS uid,
    COALESCE(owner.uid, base.owner_uid) AS bookmark_target_user_id,
    COALESCE(base.data->>'genderType', fav.data->>'genderType') AS user_gender_code,
    COALESCE(base.data->>'ageType', fav.data->>'ageType') AS user_agg_code,
    NULL AS user_type_code,
    base.bookmark_uid || '_' || base.owner_uid,
    COALESCE(fn_safe_timestamp(base.data->>'createAt'), base.created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(base.data->>'updateAt'), base.updated_at),
    'migration',
    'N'
  FROM base
  LEFT JOIN jindamhair.tb_user owner
    ON owner.migration_id = base.owner_uid
  LEFT JOIN jindamhair.tb_user target
    ON target.migration_id = base.bookmark_uid
  LEFT JOIN fs_users fav
    ON COALESCE(fav.data->>'uid', fav.data->>'id', fav.doc_id) = base.bookmark_uid
  WHERE COALESCE(base.owner_uid, '') <> ''
    AND COALESCE(base.bookmark_uid, '') <> ''
  ON CONFLICT (user_bookmark_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_user_bookmark');
END;
$$;
