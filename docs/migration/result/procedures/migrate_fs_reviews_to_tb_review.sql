-- migrate_fs_reviews_to_tb_review.sql
-- Firestore fs_reviews -> tb_review 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_reviews_to_tb_review()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_review RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_review (
    review_id,
    appointment_id,
    review_type_code_arr,
    review_content,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    data->>'appointmentId',
    CASE
      WHEN jsonb_typeof(data->'reviewType') = 'array' THEN
        ARRAY(SELECT jsonb_array_elements_text(data->'reviewType'))
      ELSE NULL
    END,
    data->>'reviewContent',
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    COALESCE(fn_safe_timestamp(data->>'updateAt'), updated_at),
    'migration',
    'N'
  FROM fs_reviews
  ON CONFLICT (review_id) DO NOTHING;
END;
$$;
