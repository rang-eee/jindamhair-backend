-- common_functions.sql
-- 공통 함수 정의 (Migration 공용)
-- 필요 시 선택적으로 실행

-- 문자열 Timestamp를 안전하게 timestamp로 변환
CREATE OR REPLACE FUNCTION fn_safe_timestamp(val text)
RETURNS timestamp AS $$
BEGIN
  IF val IS NULL OR trim(val) = '' THEN
    RETURN NULL;
  END IF;
  RETURN val::timestamp;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 문자열 Boolean을 안전하게 boolean으로 변환
CREATE OR REPLACE FUNCTION fn_safe_boolean(val text)
RETURNS boolean AS $$
BEGIN
  IF val IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN val::boolean;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;



create schema if not exists jindamhair;

create or replace function jindamhair.try_timestamptz(p_text text)
returns timestamptz
language plpgsql
immutable
as $$
declare
  v text := nullif(btrim(p_text), '');
begin
  if v is null then
    return null;
  end if;

  -- epoch millis (13자리)
  if v ~ '^\d{13}$' then
    return to_timestamp((v::numeric) / 1000.0);
  end if;

  -- epoch seconds (10자리)
  if v ~ '^\d{10}$' then
    return to_timestamp(v::numeric);
  end if;

  -- ISO-8601 or timestamptz cast
  return v::timestamptz;

exception
  when others then
    return null;
end;
$$;

-- 공백 문자열 -> NULL 치환 (PK 제외, 문자형 컬럼 대상)
create or replace function jindamhair.normalize_blank_to_null(p_schema text, p_table text)
returns void
language plpgsql
as $$
declare
  rec record;
  pk_cols text[];
  set_exprs text := '';
begin
  select array_agg(att.attname::text order by att.attnum)
    into pk_cols
  from pg_index idx
  join pg_attribute att
    on att.attrelid = idx.indrelid
   and att.attnum = any(idx.indkey)
  join pg_class cls on cls.oid = idx.indrelid
  join pg_namespace nsp on nsp.oid = cls.relnamespace
  where idx.indisprimary
    and nsp.nspname = p_schema
    and cls.relname = p_table;

  for rec in
    select column_name
    from information_schema.columns
    where table_schema = p_schema
      and table_name = p_table
      and data_type in ('character varying', 'character', 'text')
  loop
    if pk_cols is not null and rec.column_name = any(pk_cols) then
      continue;
    end if;
    if set_exprs <> '' then
      set_exprs := set_exprs || ', ';
    end if;
    set_exprs := set_exprs || format('%I = NULLIF(BTRIM(%I), '''')', rec.column_name, rec.column_name);
  end loop;

  if set_exprs <> '' then
    execute format('UPDATE %I.%I SET %s', p_schema, p_table, set_exprs);
  end if;
end;
$$;

-- 배열 컬럼(문자 배열) 내 공백/빈값 제거 후 빈 배열 -> NULL 치환
create or replace function jindamhair.normalize_blank_array_to_null(p_schema text, p_table text)
returns void
language plpgsql
as $$
declare
  rec record;
  set_exprs text := '';
begin
  for rec in
    select column_name
    from information_schema.columns
    where table_schema = p_schema
      and table_name = p_table
      and data_type = 'ARRAY'
      and udt_name in ('_varchar', '_text', '_bpchar')
  loop
    if set_exprs <> '' then
      set_exprs := set_exprs || ', ';
    end if;
    set_exprs := set_exprs || format(
      '%I = CASE WHEN %I IS NULL THEN NULL ELSE NULLIF(ARRAY(SELECT NULLIF(BTRIM(x), '''') FROM unnest(%I) AS x WHERE NULLIF(BTRIM(x), '''') IS NOT NULL), ''{}'') END',
      rec.column_name,
      rec.column_name,
      rec.column_name
    );
  end loop;

  if set_exprs <> '' then
    execute format('UPDATE %I.%I SET %s', p_schema, p_table, set_exprs);
  end if;
end;
$$;

-- 시퀀스 일괄 초기화 (RESTART WITH 1)
create or replace function jindamhair.reset_migration_sequences_to_1()
returns void
language plpgsql
as $$
declare
  seq_list text[] := array[
    'seq_tb_admin_notification_admin_notification_id',
    'seq_tb_appointment_appointment_id',
    'seq_tb_appointment_sign_appointment_sign_id',
    'seq_tb_appointment_style_hair_style_id',
    'seq_tb_appointment_treatment_appointment_treatment_id',
    'seq_tb_banner_banner_id',
    'seq_tb_chatroom_chatroom_id',
    'seq_tb_chatroom_member_chatroom_member_id',
    'seq_tb_chatroom_message_chat_message_id',
    'seq_tb_code_group_code_group_id',
    'seq_tb_code_item_code_item_id',
    'seq_tb_deeplink_deeplink_id',
    'seq_tb_designer_off_off_id',
    'seq_tb_designer_review_designer_review_id',
    'seq_tb_designer_shop_designer_shop_id',
    'seq_tb_desinger_style_add_designer_style_add_id',
    'seq_tb_desinger_style_hair_style_id',
    'seq_tb_desinger_treatment_add_designer_treatment_add_id',
    'seq_tb_desinger_treatment_designer_treatment_id',
    'seq_tb_file_file_id',
    'seq_tb_log_error_idx',
    'seq_tb_notification_center_notification_center_id',
    'seq_tb_notification_notification_id',
    'seq_tb_offer_designer_offer_designer_id',
    'seq_tb_offer_offer_id',
    'seq_tb_offer_treatment_offer_treatment_id',
    'seq_tb_payment_payment_id',
    'seq_tb_recommand_recommand_id',
    'seq_tb_review_review_id',
    'seq_tb_shop_shop_id',
    'seq_tb_treatment_class_treatment_class_id',
    'seq_tb_treatment_treatment_class_id',
    'seq_tb_treatment_treatment_id',
    'seq_tb_user_bookmark_user_bookmark_id',
    'seq_tb_user_push_user_push_id'
  ];
  seq_name text;
begin
  foreach seq_name in array seq_list loop
    execute format('alter sequence if exists jindamhair.%I restart with 1', seq_name);
  end loop;
end;
$$;

