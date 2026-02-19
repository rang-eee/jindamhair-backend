-- migrate_fs_statistics_to_tb_recommand.sql
-- Firestore fs_statistics -> tb_recommand 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_statistics_to_tb_recommand()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_recommand RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_recommand (
    recommand_id,
    uid,
    recommand_count,
    recommand_join_uid_arr,
    migration_id,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    nextval('seq_tb_recommand_recommand_id')::text,
    COALESCE(u.uid, data->>'designerUid'),
    NULLIF(data->>'designerRecommendCount', '')::numeric,
    CASE
      WHEN jsonb_typeof(data->'joinUserUids') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'joinUserUids'))
      ELSE NULL
    END,
    COALESCE(data->>'id', doc_id),
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_statistics s
  LEFT JOIN jindamhair.tb_user u
    ON u.migration_id = s.data->>'designerUid'
  ON CONFLICT (recommand_id) DO NOTHING;
  PERFORM jindamhair.normalize_blank_to_null('jindamhair', 'tb_recommand');
END;
$$;
