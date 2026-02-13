# PostgreSQL Procedure Migration Guide

## 1. 개요

본 문서는 **Firestore → PostgreSQL 마이그레이션 이후**
`fs_*` 임시 테이블의 데이터를 **업무용 테이블(tb_*)로 이관하기 위한**
PostgreSQL 프로시저 작성 가이드이다.

- 대상 DB: PostgreSQL
- 입력 테이블: `fs_*` (Firestore Raw Data)
- 출력 테이블: `tb_*` (업무용 정규 테이블)
- 기준 문서: AS-IS Firestore 구조

---

## 2. 디렉토리 구조 규칙

프로시저 결과물은 다음 경로에 위치한다.

```
docs/migration/result/procedures
├── common
│   └── common_functions.sql
├── deeplink
│   └── migrate_fs_dynamiclinks_to_tb_deeplink.sql
└── README.md
```

### 규칙
- **1 프로시저 = 1 파일**
- 파일명은 반드시 `migrate_{source}_to_{target}.sql`
- 실행 단위는 **프로시저 단독 실행 가능**해야 한다

---

## 3. 프로시저 기본 작성 규칙

### 3.1 트랜잭션 처리

모든 프로시저는 내부에서 트랜잭션을 관리한다.

```sql
BEGIN
  -- logic
EXCEPTION WHEN OTHERS THEN
  RAISE;
END;
```

---

### 3.2 멱등성(Idempotency)

- 동일 프로시저를 여러 번 실행해도 결과가 중복되지 않아야 한다
- 기준 키 충돌 시 `ON CONFLICT DO NOTHING` 또는 `UPDATE` 사용

---

### 3.3 삭제 데이터 처리

- `delete_yn = 'Y'` 데이터는 기본적으로 **이관 대상에서 제외**
- 필요 시 별도 명시

### 3.4 실행 전 데이터 초기화
모든 이관 프로시저는 **기존 `tb_*` 테이블을 TRUNCATE 한 뒤 실행**한다.

> 예: `TRUNCATE TABLE jindamhair.tb_banner RESTART IDENTITY CASCADE;`

---

## 4. JSON 데이터 추출 규칙

### 4.1 JSONB → 컬럼 매핑

```sql
(data->>'fieldName')::text
(data->>'amount')::numeric
(data->>'createAt')::timestamp
```

### 4.2 없는 필드 처리

- 존재하지 않는 JSON Key는 `NULL` 처리
- `COALESCE` 사용 가능

---

## 5. 공통 함수 (선택)

여러 프로시저에서 공통으로 사용하는 함수는  
`common/common_functions.sql` 에 정의한다.

### 예시: JSON Timestamp 변환

```sql
CREATE OR REPLACE FUNCTION fn_json_to_timestamp(val text)
RETURNS timestamp AS $$
BEGIN
  IF val IS NULL THEN
    RETURN NULL;
  END IF;
  RETURN val::timestamp;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

> 공통 함수가 불필요한 경우 `common` 디렉토리는 생략 가능

---

## 6. 예시: fs_dynamiclinks → tb_deeplink

### 파일 경로

```
result/procedures/deeplink/migrate_fs_dynamiclinks_to_tb_deeplink.sql
```

### 프로시저 예시

```sql
CREATE OR REPLACE PROCEDURE migrate_fs_dynamiclinks_to_tb_deeplink()
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO jindamhair.tb_deeplink (
    deeplink_id,
    deeplink_key,
    deeplink_email,
    deeplink_url,
    create_at
  )
  SELECT
    doc_id,
    data->>'key',
    data->>'email',
    data->>'url',
    COALESCE(created_at, now())
  FROM fs_dynamiclinks
  WHERE COALESCE(data->>'deleteYn', 'N') <> 'Y'
  ON CONFLICT (deeplink_id) DO NOTHING;
END;
$$;
```

---

## 7. 실행 순서 가이드

1. `fs_*` 테이블 생성
2. Firestore → fs_* 데이터 적재
3. (선택) `common_functions.sql` 실행
4. 개별 마이그레이션 프로시저 실행
5. 결과 검증

---

## 8. 주의 사항

- 프로시저 내부에서 `COMMIT` / `ROLLBACK` 직접 호출 금지
- 대용량 데이터는 **배치 단위 INSERT** 권장
- 운영 DB 실행 전 반드시 **스테이징 검증**

---

## 9. 다음 단계

- TO-BE 데이터 모델 확정
- 전체 프로시저 실행 순서 문서화
- Validation / Count Check SQL 작성

---

## 10. 기준 스키마 프로시저 작업 여부

### 10.1 AS-IS 스키마(컬렉션) 기준

| 컬렉션 | 작업 여부 | 비고 |
|---|---|---|
| alerts | ✅ 완료 | 1:1 |
| appointments | ✅ 완료 | 조인형 |
| banners | ✅ 완료 | 1:1 |
| chatRooms | ✅ 완료 | 조인형 |
| configuration | ✅ 완료 | 1:1 |
| dynamicLinks | ✅ 완료 | 1:1 |
| notifications | ✅ 완료 | 1:1 |
| offers | ✅ 완료 | 조인형 (tb_offer / tb_offer_treatment / tb_offer_designer 분리) |
| payments | ✅ 완료 | 1:1 |
| pushes | ✅ 완료 | 1:1 |
| reservations | ✅ 완료 | 조인형 (tb_appointment / tb_appointment_treatment / tb_appointment_sign 포함) |
| reviews | ✅ 완료 | 1:1 |
| statistics | ✅ 완료 | 1:1 |
| stores | ✅ 완료 | 1:1 |
| treatmentClassfications | ✅ 완료 | 1:1 |
| treatments | ✅ 완료 | 1:1 |
| users | ✅ 완료 | 1:1 |
| usersFavorites | ❌ 미진행 | 2차 대상 |

### 10.2 TO-BE 스키마(테이블) 기준

| 테이블 | 작업 여부 | 비고 |
|---|---|---|
| tb_log_error | 제외 | 마이그레이션 대상 아님 |
| tb_file | ✅ 완료 | users.designerLicenseImageUrl / users.designerPhotos[] / users.imageUrl / users.menus.hairImageUrl[] |
| tb_configuration | ✅ 완료 | 1:1 |
| tb_treatment | ✅ 완료 | 1:1 |
| tb_treatment_class | ✅ 완료 | 1:1 |
| tb_deeplink | ✅ 완료 | 1:1 |
| tb_shop | ✅ 완료 | 1:1 |
| tb_appointment | ✅ 완료 | 1:1 (appointments + reservations) |
| tb_appointment_treatment | ✅ 완료 | 조인형 (appointments.menus + reservations.menus) |
| tb_appointment_sign | ✅ 완료 | 조인형 (appointments.sign) |
| tb_payment | ✅ 완료 | 1:1 |
| tb_user_push | ✅ 완료 | 1:1 |
| tb_admin_notification | ✅ 완료 | 1:1 |
| tb_notification | ✅ 완료 | 1:1 |
| tb_chatroom | ✅ 완료 | 조인형 |
| tb_chatroom_member | ✅ 완료 | 조인형 |
| tb_chatroom_message | ✅ 완료 | 조인형 |
| tb_banner | ✅ 완료 | 1:1 |
| tb_review | ✅ 완료 | 1:1 |
| tb_designer_review | ✅ 완료 | 조인형 |
| tb_recommand | ✅ 완료 | 1:1 |
| tb_offer | ✅ 완료 | 1:1 |
| tb_offer_treatment | ✅ 완료 | 조인형 |
| tb_offer_designer | ✅ 완료 | 조인형 |
| tb_user_bookmark | ✅ 완료 | 조인형 |
| tb_user | ✅ 완료 | 1:1 |
| tb_designer_shop | ✅ 완료 | 조인형 |
| tb_designer_off | ✅ 완료 | 조인형 |
| tb_desinger_treatment | ✅ 완료 | 조인형 |
| tb_desinger_treatment_add | ✅ 완료 | 조인형 |
| tb_notification_center | ✅ 완료 | 조인형 |
