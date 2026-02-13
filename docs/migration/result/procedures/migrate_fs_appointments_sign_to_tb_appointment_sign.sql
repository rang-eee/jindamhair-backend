-- migrate_fs_appointments_sign_to_tb_appointment_sign.sql
-- Firestore fs_appointments__sign -> tb_appointment_sign 이관 프로시저

CREATE OR REPLACE PROCEDURE migrate_fs_appointments_sign_to_tb_appointment_sign()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE jindamhair.tb_appointment_sign RESTART IDENTITY CASCADE;

  INSERT INTO jindamhair.tb_appointment_sign (
    appointment_sign_id,
    appointment_id,
    sign_offset_x,
    sign_offset_y,
    sign_size,
    sign_color,
    sort_order,
    create_at,
    create_id,
    update_at,
    update_id,
    delete_yn
  )
  SELECT
    COALESCE(data->>'id', doc_id),
    parent_doc_id,
    data->>'signOffsetX',
    data->>'signOffsetY',
    data->>'signSize',
    data->>'signColor',
    CASE WHEN (data->>'sortOrder') ~ '^[0-9]+$' THEN (data->>'sortOrder')::numeric ELSE NULL END,
    COALESCE(fn_safe_timestamp(data->>'createAt'), created_at, now()),
    'migration',
    updated_at,
    'migration',
    'N'
  FROM fs_appointments__sign
  ON CONFLICT (appointment_sign_id) DO NOTHING;
END;
$$;
