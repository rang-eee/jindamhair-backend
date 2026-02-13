-- migrate_fs_users_to_tb_designer_review.sql
-- Firestore fs_users -> tb_designer_review 이관 프로시저 (users.reviewCount Map 기반)

CREATE OR REPLACE PROCEDURE migrate_fs_users_to_tb_designer_review()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_designer_review RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_designer_review (
    designer_review_id,
    review_type_code,
    review_count,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    uid || '_' || review_type_code AS designer_review_id,
    review_type_code,
    review_count,
    COALESCE(fn_safe_timestamp(user_create_at), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM (
    SELECT
      COALESCE(u.data->>'uid', u.data->>'id', u.doc_id) AS uid,
      u.data->>'createAt' AS user_create_at,
      u.created_at,
      u.updated_at,
      k AS review_type_code,
      CASE
        WHEN (v)::text ~ '^[0-9]+(\\.[0-9]+)?$' THEN (v)::numeric
        ELSE NULL
      END AS review_count
    FROM fs_users u
    JOIN LATERAL jsonb_each_text(u.data->'reviewCount') AS rc(k, v)
      ON jsonb_typeof(u.data->'reviewCount') = 'object'
  ) t
  WHERE uid IS NOT NULL AND uid <> ''
    AND review_type_code IS NOT NULL AND review_type_code <> ''
  ON CONFLICT (designer_review_id) DO NOTHING;
END;
$$;
