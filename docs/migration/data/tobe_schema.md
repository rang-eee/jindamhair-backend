# JindamHair TO-BE DB Spec (Full Table Spec)

> 기준: 사용자 제공 DDL/COMMENT 스니펫 (일부 구간은 원본 DDL에 오탈자가 있어 그대로 표기하고, 명확하지 않은 부분은 `<UNKNOWN>` 처리)

---

## 공통 규칙 (관례)

- 대부분 테이블에 아래 공통 컬럼이 존재
  - `create_at timestamp NOT NULL DEFAULT now()`
  - `create_id text NULL`
  - `update_at timestamp NULL`
  - `update_id text NULL`
  - `delete_yn bpchar(1) NOT NULL DEFAULT 'N'`
  - `delete_at timestamp NULL`
  - `delete_id text NULL`
- PK는 `CONSTRAINT pk_* PRIMARY KEY (...)` 로 정의됨
- 시퀀스는 `jindamhair.seq_tb_*` 형태로 존재(최대 999999, CYCLE)

---

## 1) 로그/파일/설정

### 1.1 `tb_log_error` (에러 로그)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `idx` | `text` | NOT NULL |  | ✅ | 인덱스 |
| `request_info` | `text` | NULL |  |  | 요청 정보 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |

---

### 1.2 `tb_file` (파일)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `file_id` | `text` | NOT NULL |  | ✅ | 파일 ID |
| `sort_order` | `numeric` | NULL |  |  | 정렬 순서 |
| `file_type_code` | `varchar(30)` | NULL |  |  | 파일 유형 코드. FLTP |
| `org_file_name` | `text` | NULL |  |  | 원본 파일 명 |
| `convert_file_name` | `text` | NULL |  |  | 변환 파일 명 |
| `file_path` | `text` | NULL |  |  | 파일 경로 |
| `file_size` | `_varchar` | NULL |  |  | 파일 사이즈 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 1.3 `tb_configuration` (설정)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `aos_last_ver` | `text` | NULL |  |  | AOS 최종 버젼 |
| `aos_permission_minimum_build_number` | `text` | NULL |  |  | AOS 허용 최소 빌드 번호 |
| `ios_last_ver` | `text` | NULL |  |  | IOS 최종 버젼 |
| `ios_permission_minimum_build_number` | `text` | NULL |  |  | IOS 허용 최소 빌드 번호 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NOT NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |

> 주의: 제공 DDL에는 PK 제약이 없음(설계상 단일 row 테이블일 가능성)

---

## 2) 사용자/디자이너

### 2.1 `tb_user` (사용자)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `uid` | `text` | NOT NULL |  | ✅ | 사용자ID |
| `user_email` | `text` | NULL |  |  | 사용자 이메일 |
| `user_contact` | `text` | NULL |  |  | 사용자 연락처 |
| `user_name` | `text` | NULL |  |  | 사용자 명 |
| `user_nickname` | `text` | NULL |  |  | 사용자 닉네임 |
| `user_status_code` | `varchar(30)` | NULL |  |  | 사용자 상태 코드. USST |
| `user_gender_code` | `varchar(30)` | NULL |  |  | 사용자 성별 코드. USGD |
| `user_agg_code` | `varchar(30)` | NULL |  |  | 사용자 연령대 코드. USAG |
| `user_type_code` | `varchar(30)` | NULL |  |  | 사용자 유형 코드. USTP |
| `user_brdt` | `text` | NULL |  |  | 사용자 생년월일 |
| `user_join_type_code` | `varchar(30)` | NULL |  |  | 사용자 가입 유형 코드. UJTP |
| `push_token` | `text` | NULL |  |  | 푸시 토큰 |
| `last_login_at` | `timestamp` | NULL |  |  | 최종 로그인 일시 |
| `bookmark_user_id_arr` | `_varchar` | NULL |  |  | 즐겨찾기 사용자 ID 배열 |
| `interception_user_id_arr` | `_varchar` | NULL |  |  | 차단 사용자 ID 배열 |
| `prvcplc_agree_yn` | `bpchar(1)` | NULL |  |  | 개인정보처리방침 동의 여부 |
| `terms_agree_yn` | `bpchar(1)` | NULL |  |  | 서비스 이용약관 동의 여부 |
| `all_notification_reception_yn` | `bpchar(1)` | NULL |  |  | 전체 알림 수신 여부 |
| `all_notification_reception_at` | `timestamp` | NULL |  |  | 전체 알림 수신 일시 |
| `notice_notification_reception_yn` | `bpchar(1)` | NULL |  |  | 공지 알림 수신 여부 |
| `notice_notification_reception_at` | `timestamp` | NULL |  |  | 공지 알림 수신 일시 |
| `marketing_notification_reception_yn` | `bpchar(1)` | NULL |  |  | 마케팅 알림 수신 여부 |
| `marketing_notification_reception_at` | `timestamp` | NULL |  |  | 마케팅 알림 수신 일시 |
| `offer_notification_reception_yn` | `bpchar(1)` | NULL |  |  | 제안 알림 수신 여부 |
| `offer_notification_reception_at` | `timestamp` | NULL |  |  | 제안 알림 수신 일시 |
| `chat_notification_reception_yn` | `bpchar(1)` | NULL |  |  | 채팅 알림 수신 여부 |
| `chat_notification_reception_at` | `timestamp` | NULL |  |  | 채팅 알림 수신 일시 |
| `appointment_notification_reception_yn` | `bpchar(1)` | NULL |  |  | 예약 알림 수신 여부 |
| `appointment_notification_reception_at` | `timestamp` | NULL |  |  | 예약 알림 수신 일시 |
| `position_addr` | `text` | NULL |  |  | 위치 주소 |
| `position_latt` | `text` | NULL |  |  | 위치 위도 |
| `position_lngt` | `text` | NULL |  |  | 위치 경도 |
| `position_distance` | `text` | NULL |  |  | 위치 거리 |
| `profile_photo_file_id` | `text` | NULL |  |  | 프로필 사진 파일 ID |
| `designer_appr_status_code` | `varchar(30)` | NULL |  |  | 디자이너 승인 상태 코드. DAST |
| `designer_introduce_content` | `text` | NULL |  |  | 디자이너 소개 내용 |
| `designer_tag_arr` | `_varchar` | NULL |  |  | 디자이너 태그 배열 |
| `designer_work_status_code` | `varchar(30)` | NULL |  |  | 디자이너 근무 상태 코드. DWST |
| `designer_open_day_arr` | `_varchar` | NULL |  |  | 디자이너 오픈 요일 배열 |
| `designer_open_time_arr` | `_varchar` | NULL |  |  | 디자이너 오픈 시간 배열 |
| `designer_close_time_arr` | `_varchar` | NULL |  |  | 디자이너 오프 시간 배열 |
| `designer_appointment_automatic_confirm_yn` | `bpchar(1)` | NULL |  |  | 디자이너 예약 자동 확정 여부 |
| `designer_applink_url` | `text` | NULL |  |  | 디자이너 앱링크 URL |
| `designer_detail_photo_file_id` | `text` | NULL |  |  | 디자이너 세부 사진 파일 ID |
| `designer_account_brand_code` | `varchar(30)` | NULL |  |  | 디자이너 계좌 브랜드 코드. DABT |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 2.2 `tb_designer_off` (디자이너 휴무)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `off_id` | `text` | NOT NULL |  | ✅ | 휴무 ID |
| `uid` | `text` | NULL |  |  | 사용자ID |
| `off_at` | `timestamp` | NULL |  |  | 휴무 일시 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 2.3 `tb_desinger_treatment` (디자이너 시술)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `designer_treatment_id` | `text` | NOT NULL |  | ✅ | 디자이너 시술 ID |
| `uid` | `text` | NULL |  |  | 사용자ID |
| `treatment_name` | `text` | NULL |  |  | 시술 명 |
| `basic_amount` | `numeric` | NULL |  |  | 기본 금액 |
| `discount_pt` | `numeric` | NULL |  |  | 할인 백분율 |
| `discount_amount` | `numeric` | NULL |  |  | 할인 금액 |
| `total_amount` | `numeric` | NULL |  |  | 총 금액 |
| `treatment_content` | `numeric` | NULL |  |  | 시술 내용 |
| `treatment_require_time` | `numeric` | NULL |  |  | 시술 소요 시간 |
| `treatment_photo_file_id` | `text` | NULL |  |  | 시술 사진 파일 ID |
| `treatment_gender_type_code` | `varchar(30)` | NULL |  |  | 시술 성별 유형 코드. TGTP |
| `discount_yn` | `bpchar(1)` | NULL |  |  | 할인 여부 |
| `add_yn` | `bpchar(1)` | NULL |  |  | 추가 여부 |
| `open_yn` | `bpchar(1)` | NULL |  |  | 오픈 여부 |
| `sort_order` | `numeric` | NULL |  |  | 정렬 순서 |
| `treatment_code_1` | `varchar(30)` | NULL |  |  | 시술 코드 1 |
| `treatment_name_1` | `text` | NULL |  |  | 시술 명 1 |
| `treatment_code_2` | `varchar(30)` | NULL |  |  | 시술 코드 2 |
| `treatment_name_2` | `text` | NULL |  |  | 시술 명 2 |
| `treatment_code_3` | `varchar(30)` | NULL |  |  | 시술 코드 3 |
| `treatment_name_3` | `text` | NULL |  |  | 시술 명 3 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 2.4 `tb_desinger_treatment_add` (디자이너 시술 추가)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `designer_treatment_add_id` | `text` | NOT NULL |  | ✅ | 디자이너 시술 추가 ID |
| `designer_treatment_id` | `text` | NULL |  |  | 디자이너 시술 ID |
| `hair_add_type_code` | `varchar(30)` | NULL |  |  | 헤어 추가 유형 코드. HATP |
| `add_amount` | `numeric` | NULL |  |  | 추가 금액 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

## 3) 마스터 시술

### 3.1 `tb_treatment` (시술)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `treatment_id` | `text` | NOT NULL |  | ✅ | 시술 ID |
| `treatment_code` | `varchar(30)` | NULL |  |  | 시술 코드 |
| `treatment_name` | `text` | NULL |  |  | 시술 명 |
| `treatment_level` | `numeric` | NULL |  |  | 시술 레벨 |
| `sort_order` | `numeric` | NULL |  |  | 정렬 순서 |
| `offer_minimum_amount` | `numeric` | NULL |  |  | 제안 최소 금액 |
| `use_yn` | `bpchar(1)` | NOT NULL | `'Y'` |  | 사용 여부 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 3.2 `tb_treatment_class` (시술 분류)

> 제공 DDL에 오탈자 존재: `DROP TABLE IF EXISTS ... tb_treatment;` / `CREATE TABLE ... tb_treatment (` 로 되어있으나, COMMENT/GRANT는 `tb_treatment_class` 대상으로 작성됨.  
> 여기서는 의도대로 **`tb_treatment_class`** 로 정리.

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `treatment_class_id` | `text` | NOT NULL |  | ✅ | 시술 분류 ID |
| `treatment_code` | `varchar(30)` | NULL |  |  | 시술 코드 |
| `treatment_name` | `text` | NULL |  |  | 시술 명 |
| `treatment_level` | `numeric` | NULL |  |  | 시술 레벨 |
| `treatment_code_1` | `varchar(30)` | NULL |  |  | 시술 코드 1 |
| `treatment_name_1` | `text` | NULL |  |  | 시술 명 1 |
| `treatment_code_2` | `varchar(30)` | NULL |  |  | 시술 코드 2 |
| `treatment_name_2` | `text` | NULL |  |  | 시술 명 2 |
| `treatment_code_3` | `varchar(30)` | NULL |  |  | 시술 코드 3 |
| `treatment_name_3` | `text` | NULL |  |  | 시술 명 3 |
| `sort_order` | `numeric` | NULL |  |  | 정렬 순서 |
| `use_yn` | `bpchar(1)` | NOT NULL | `'Y'` |  | 사용 여부 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

## 4) 딥링크/매장

### 4.1 `tb_deeplink` (딥링크)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `deeplink_id` | `text` | NOT NULL |  | ✅ | 딥링크 ID |
| `deeplink_key` | `text` | NULL |  |  | 딥링크 키 |
| `deeplink_email` | `text` | NULL |  |  | 딥링크 이메일 |
| `deeplink_url` | `text` | NULL |  |  | 딥링크 URL |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 4.2 `tb_shop` (헤어샵)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `shop_id` | `text` | NOT NULL |  | ✅ | 헤어샵 ID |
| `shop_name` | `text` | NULL |  |  | 헤어샵 명 |
| `shop_description` | `text` | NULL |  |  | 헤어샵 설명 |
| `shop_addr` | `text` | NULL |  |  | 헤어샵 주소 |
| `shop_addr_detail` | `text` | NULL |  |  | 헤어샵 주소 상세 |
| `shop_contact` | `text` | NULL |  |  | 헤어샵 연락처 |
| `position_lngt` | `text` | NULL |  |  | 위치 경도 |
| `position_latt` | `text` | NULL |  |  | 위치 위도 |
| `zipcode` | `text` | NULL |  |  | 우편번호 |
| `use_yn` | `bpchar(1)` | NOT NULL | `'Y'` |  | 사용 여부 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 4.3 `tb_designer_shop` (디자이너 헤어샵)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `designer_shop_id` | `text` | NOT NULL |  | ✅ | 디자이너 헤어샵 ID |
| `uid` | `text` | NULL |  |  | 사용자ID |
| `shop_id` | `text` | NULL |  |  | 헤어샵 ID |
| `shop_regist_type_code` | `varchar(30)` | NULL |  |  | 헤어샵 등록 유형 코드. SRTP |
| `representative_yn` | `bpchar(1)` | NULL |  |  | 대표 여부 |
| `shop_name` | `text` | NULL |  |  | 헤어샵 명. 추가 매장용 컬럼 |
| `shop_description` | `text` | NULL |  |  | 헤어샵 설명. 추가 매장용 컬럼 |
| `shop_addr` | `text` | NULL |  |  | 헤어샵 주소. 추가 매장용 컬럼 |
| `shop_addr_detail` | `text` | NULL |  |  | 헤어샵 주소 상세. 추가 매장용 컬럼 |
| `shop_contact` | `text` | NULL |  |  | 헤어샵 연락처. 추가 매장용 컬럼 |
| `position_lngt` | `text` | NULL |  |  | 위치 경도. 추가 매장용 컬럼 |
| `position_latt` | `text` | NULL |  |  | 위치 위도. 추가 매장용 컬럼 |
| `zipcode` | `text` | NULL |  |  | 우편번호. 추가 매장용 컬럼 |
| `use_yn` | `bpchar(1)` | NOT NULL | `'Y'` |  | 사용 여부. 추가 매장용 컬럼 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

## 5) 예약/서명/예약시술

### 5.1 `tb_appointment` (예약)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `appointment_id` | `text` | NOT NULL |  | ✅ | 예약 ID |
| `customer_uid` | `text` | NULL |  |  | 고객 사용자ID |
| `designer_uid` | `text` | NULL |  |  | 디자이너 사용자ID |
| `designer_shop_id` | `text` | NULL |  |  | 디자이너 헤어샵 ID |
| `appointment_status_code` | `varchar(30)` | NULL |  |  | 예약 상태 코드. APST |
| `appointment_start_type_code` | `varchar(30)` | NULL |  |  | 예약 시작 유형 코드. APSR |
| `total_amount` | `numeric` | NULL |  |  | 총 금액 |
| `appointment_amount` | `numeric` | NULL |  |  | 예약 금액 |
| `treatment_start_at` | `timestamp` | NULL |  |  | 시술 시작 일시 |
| `treatment_end_at` | `timestamp` | NULL |  |  | 시술 종료 일시 |
| `payment_method_code` | `varchar(30)` | NULL |  |  | 결제 방법 코드. PMMT |
| `appointment_content` | `text` | NULL |  |  | 예약 내용 |
| `cancel_reason_content` | `text` | NULL |  |  | 취소 사유 내용 |
| `review_id` | `text` | NULL |  |  | 후기 ID |
| `customer_name` | `text` | NULL |  |  | 고객 명. 이력성 데이터 |
| `customer_nickname` | `text` | NULL |  |  | 고객 닉네임. 이력성 데이터 |
| `customer_contact` | `text` | NULL |  |  | 고객 연락처. 이력성 데이터 |
| `designer_name` | `text` | NULL |  |  | 디자이너 명. 이력성 데이터 |
| `designer_nickname` | `text` | NULL |  |  | 디자이너 닉네임. 이력성 데이터 |
| `designer_contact` | `text` | NULL |  |  | 디자이너 연락처. 이력성 데이터 |
| `shop_name` | `text` | NULL |  |  | 헤어샵 명. 이력성 데이터 |
| `shop_addr` | `text` | NULL |  |  | 헤어샵 주소. 이력성 데이터. 상세 주소 포함 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 5.2 `tb_appointment_treatment` (예약 시술)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `appointment_treatment_id` | `text` | NOT NULL |  | ✅ | 예약 시술 ID |
| `designer_treatment_id` | `text` | NULL |  |  | 디자이너 시술 ID |
| `uid` | `text` | NULL |  |  | 사용자ID |
| `treatment_name` | `text` | NULL |  |  | 시술 명 |
| `basic_amount` | `numeric` | NULL |  |  | 기본 금액 |
| `discount_pt` | `numeric` | NULL |  |  | 할인 백분율 |
| `discount_amount` | `numeric` | NULL |  |  | 할인 금액 |
| `hair_add_type_code` | `varchar(30)` | NULL |  |  | 헤어 추가 유형 코드 |
| `add_amount` | `numeric` | NULL |  |  | 추가 금액 |
| `total_amount` | `numeric` | NULL |  |  | 총 금액 |
| `treatment_content` | `numeric` | NULL |  |  | 시술 내용 |
| `treatment_require_time` | `numeric` | NULL |  |  | 시술 소요 시간 |
| `treatment_photo_file_id` | `text` | NULL |  |  | 시술 사진 파일 ID |
| `treatment_gender_type_code` | `varchar(30)` | NULL |  |  | 시술 성별 유형 코드. TGTP |
| `discount_yn` | `bpchar(1)` | NULL |  |  | 할인 여부 |
| `add_yn` | `bpchar(1)` | NULL |  |  | 추가 여부 |
| `open_yn` | `bpchar(1)` | NULL |  |  | 오픈 여부 |
| `treatment_code_1` | `varchar(30)` | NULL |  |  | 시술 코드 1 |
| `treatment_name_1` | `text` | NULL |  |  | 시술 명 1 |
| `treatment_code_2` | `varchar(30)` | NULL |  |  | 시술 코드 2 |
| `treatment_name_2` | `text` | NULL |  |  | 시술 명 2 |
| `treatment_code_3` | `varchar(30)` | NULL |  |  | 시술 코드 3 |
| `treatment_name_3` | `text` | NULL |  |  | 시술 명 3 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 5.3 `tb_appointment_sign` (예약 서명)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `appointment_sign_id` | `text` | NOT NULL |  | ✅ | 예약 서명 ID |
| `appointment_id` | `text` | NULL |  |  | 예약 ID |
| `sign_offset_x` | `text` | NULL |  |  | 서명 오프셋 X |
| `sign_offset_y` | `text` | NULL |  |  | 서명 오프셋 Y |
| `sign_size` | `text` | NULL |  |  | 서명 사이즈 |
| `sign_color` | `text` | NULL |  |  | 서명 색상 |
| `sort_order` | `numeric` | NULL |  |  | 정렬 순서 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

## 6) 채팅

### 6.1 `tb_chatroom` (채팅방)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `chatroom_id` | `text` | NOT NULL |  | ✅ | 채팅방 ID |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 6.2 `tb_chatroom_member` (채팅방 멤버)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `chatroom_member_id` | `text` | NOT NULL |  | ✅ | 채팅방 멤버 ID |
| `chatroom_id` | `text` | NULL |  |  | 채팅방 ID |
| `uid` | `text` | NULL |  |  | 사용자ID |
| `chatroom_name` | `text` | NULL |  |  | 채팅방 명 |
| `last_read_at` | `timestamp` | NULL |  |  | 최종 읽음 일시 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 6.3 `tb_chatroom_message` (채팅방 메시지)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `chat_message_id` | `text` | NOT NULL |  | ✅ | 채팅 메시지 ID |
| `chatroom_id` | `text` | NULL |  |  | 채팅방 ID |
| `write_uid` | `text` | NULL |  |  | 작성 사용자ID |
| `chat_message_type_code` | `varchar(30)` | NULL |  |  | 채팅 메시지 유형 코드. CMTP |
| `chat_message_content_type_code` | `varchar(30)` | NULL |  |  | 채팅 메시지 내용 유형 코드. CMCT |
| `chat_message_content` | `text` | NULL |  |  | 채팅 메시지 내용 |
| `delete_member_uid_arr` | `_varchar` | NULL |  |  | 삭제 멤버 사용자ID 배열 |
| `appointment_id` | `text` | NULL |  |  | 예약 ID. 후기 입력을 위한 컬럼 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

## 7) 알림/푸시

### 7.1 `tb_user_push` (사용자 푸시)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `user_push_id` | `text` | NOT NULL |  | ✅ | 사용자 푸시 ID |
| `sender_uid` | `text` | NULL |  |  | 송신자 사용자ID |
| `receiver_uid` | `text` | NULL |  |  | 수신자 사용자ID |
| `push_title` | `text` | NULL |  |  | 푸시 제목 |
| `push_content` | `text` | NULL |  |  | 푸시 내용 |
| `send_at` | `timestamp` | NULL |  |  | 송신 일시 |
| `send_yn` | `bpchar(1)` | NULL |  |  | 송신 여부 |
| `send_complete_at` | `timestamp` | NULL |  |  | 송신 완료 일시 |
| `push_type_code` | `varchar(30)` | NULL |  |  | 푸시 유형 코드. PSTP |
| `push_link_val` | `text` | NULL |  |  | 푸시 연계 값 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 7.2 `tb_admin_notification` (관리자 알림)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `admin_notification_id` | `text` | NOT NULL |  | ✅ | 관리자 알림 ID |
| `notification_sender_type_code` | `varchar(30)` | NULL |  |  | 알림 송신자 유형 코드. NTST |
| `notification_receiver_type_code` | `varchar(30)` | NULL |  |  | 알림 수신자 유형 코드. NTRT |
| `notification_send_method_code` | `varchar(30)` | NULL |  |  | 알림 송신 방법 코드. NTSM |
| `notification_send_period_type_code` | `varchar(30)` | NULL |  |  | 알림 송신 기간 유형 코드. NSPT |
| `notification_title` | `text` | NULL |  |  | 알림 제목 |
| `notification_content` | `text` | NULL |  |  | 알림 내용 |
| `send_at` | `timestamp` | NULL |  |  | 송신 일시 |
| `send_yn` | `bpchar(1)` | NULL |  |  | 송신 여부 |
| `send_complete_at` | `timestamp` | NULL |  |  | 송신 완료 일시 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 7.3 `tb_notification` (알림)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `notification_id` | `text` | NOT NULL |  | ✅ | 알림 ID |
| `receiver_uid` | `text` | NULL |  |  | 수신자 사용자ID |
| `notification_title` | `text` | NULL |  |  | 알림 제목 |
| `notification_content` | `text` | NULL |  |  | 알림 내용 |
| `notification_topic` | `text` | NULL |  |  | 알림 토픽 |
| `event_click` | `text` | NULL |  |  | 이벤트 클릭 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 7.4 `tb_notification_center` (알림 센터)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `notification_center_id` | `text` | NOT NULL |  | ✅ | 알림 센터 ID |
| `notification_topic` | `text` | NULL |  |  | 알림 토픽 |
| `event_click` | `text` | NULL |  |  | 이벤트 클릭 |
| `notification_type_code` | `varchar(30)` | NULL |  |  | 알림 유형 코드. NTTP |
| `notification_title` | `text` | NULL |  |  | 알림 제목 |
| `notification_content` | `text` | NULL |  |  | 알림 내용 |
| `receiver_uid` | `text` | NULL |  |  | 수신자 사용자ID |
| `appointment_id` | `text` | NULL |  |  | 예약 ID |
| `appointment_at` | `timestamp` | NULL |  |  | 예약 일시 |
| `designer_name` | `text` | NULL |  |  | 디자이너 명 |
| `user_name` | `text` | NULL |  |  | 사용자 명 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

## 8) 배너/제안/후기/결제/추천

### 8.1 `tb_banner` (배너)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `banner_id` | `text` | NOT NULL |  | ✅ | 배너 ID |
| `banner_title` | `text` | NULL |  |  | 배너 제목 |
| `banner_content` | `text` | NULL |  |  | 배너 내용 |
| `banner_layer_height` | `numeric` | NULL |  |  | 배너 레이어 높이 |
| `display_start_at` | `timestamp` | NULL |  |  | 노출 시작 일시 |
| `display_end_at` | `timestamp` | NULL |  |  | 노출 종료 일시 |
| `sort_order` | `numeric` | NULL |  |  | 정렬 순서 |
| `banner_type_code` | `varchar(30)` | NULL |  |  | 배너 유형 코드. BNTP |
| `banner_display_position_code` | `varchar(30)` | NULL |  |  | 배너 노출 위치 코드. BDPT |
| `banner_display_target_code` | `varchar(30)` | NULL |  |  | 배너 노출 대상 코드. BDTG |
| `banner_display_status_code` | `varchar(30)` | NULL |  |  | 배너 노출 상태 코드. BDST |
| `banner_display_time_code` | `varchar(30)` | NULL |  |  | 배너 노출 시간 코드. BDTM |
| `banner_icon_code` | `varchar(30)` | NULL |  |  | 배너 아이콘 코드. BNIC |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 8.2 `tb_offer` (제안)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `offer_id` | `text` | NOT NULL |  | ✅ | 제안 ID |
| `offer_status_code` | `varchar(30)` | NULL |  |  | 제안 상태 코드. OFST |
| `offer_uid` | `text` | NULL |  |  | 제안 사용자ID |
| `offer_at` | `timestamp` | NULL |  |  | 제안 일시 |
| `offer_amount` | `numeric` | NULL |  |  | 제안 금액 |
| `offer_position_addr` | `text` | NULL |  |  | 제안 위치 주소 |
| `offer_position_distance` | `numeric` | NULL |  |  | 제안 위치 거리 |
| `offer_position_latt` | `numeric` | NULL |  |  | 제안 위치 위도 |
| `offer_position_lngt` | `numeric` | NULL |  |  | 제안 위치 경도 |
| `offer_memo_content` | `text` | NULL |  |  | 제안 메모 내용 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |

> 제공 DDL에는 `delete_id` 컬럼이 누락되어 있음(필요 시 정책에 맞춰 추가 검토)

---

### 8.3 `tb_offer_treatment` (제안 시술)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `offer_treatment_id` | `text` | NOT NULL |  | ✅ | 제안 시술 ID |
| `offer_id` | `text` | NULL |  |  | 제안 ID |
| `treatment_level` | `numeric` | NULL |  |  | 시술 레벨 |
| `treatment_code` | `varchar(30)` | NULL |  |  | 시술 코드 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 8.4 `tb_offer_designer` (제안 디자이너)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `offer_designer_id` | `text` | NOT NULL |  | ✅ | 제안 디자이너 ID |
| `offer_id` | `text` | NULL |  |  | 제안 ID |
| `offer_agree_status_code` | `varchar(30)` | NULL |  |  | 제안 수락 상태 코드. OAST |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |

> 제공 DDL에는 `delete_id` 컬럼이 누락되어 있음(필요 시 정책에 맞춰 추가 검토)

---

### 8.5 `tb_review` (후기)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `review_id` | `text` | NOT NULL |  | ✅ | 후기 ID |
| `appointment_id` | `text` | NULL |  |  | 예약 ID |
| `review_type_code_arr` | `_varchar` | NULL |  |  | 후기 유형 코드 배열 |
| `review_content` | `text` | NULL |  |  | 후기 내용 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 8.6 `tb_designer_review` (디자이너 후기)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `designer_review_id` | `text` | NOT NULL |  | ✅ | 디자이너 후기 ID |
| `review_type_code` | `varchar(30)` | NULL |  |  | 후기 유형 코드. RVTP |
| `review_count` | `numeric` | NULL |  |  | 후기 수 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 8.7 `tb_payment` (결제)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `payment_id` | `text` | NOT NULL |  | ✅ | 결제 ID |
| `payment_type_val` | `text` | NULL |  |  | 결제 유형 값 |
| `payment_key` | `text` | NULL |  |  | 결제 키 |
| `order_id` | `numeric` | NULL |  |  | 주문 ID |
| `payment_amount` | `numeric` | NULL |  |  | 결제 금액 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

### 8.8 `tb_recommand` (추천)

| Column | Type | Null | Default | PK | Comment |
|---|---|---:|---|---:|---|
| `recommand_id` | `text` | NOT NULL |  | ✅ | 추천 ID |
| `uid` | `text` | NULL |  |  | 사용자ID |
| `recommand_count` | `numeric` | NULL |  |  | 추천 수 |
| `recommand_join_uid_arr` | `_varchar` | NULL |  |  | 추천 가입 사용자ID 배열 |
| `create_at` | `timestamp` | NOT NULL | `now()` |  | 생성 일시 |
| `create_id` | `text` | NULL |  |  | 생성 ID |
| `update_at` | `timestamp` | NULL |  |  | 수정 일시 |
| `update_id` | `text` | NULL |  |  | 수정 ID |
| `delete_yn` | `bpchar(1)` | NOT NULL | `'N'` |  | 삭제 여부 |
| `delete_at` | `timestamp` | NULL |  |  | 삭제 일시 |
| `delete_id` | `text` | NULL |  |  | 삭제 ID |

---

## 9) 시퀀스 목록 (DDL 제공분)

| Sequence | Target (추정) | Notes |
|---|---|---|
| `seq_tb_log_error_idx` | `tb_log_error.idx` | text PK지만 시퀀스 존재(정책 확인 필요) |
| `seq_tb_file_file_id` | `tb_file.file_id` |  |
| `seq_tb_designer_off_off_id` | `tb_designer_off.off_id` |  |
| `seq_tb_desinger_treatment_designer_treatment_id` | `tb_desinger_treatment.designer_treatment_id` |  |
| `seq_tb_desinger_treatment_add_designer_treatment_add_id` | `tb_desinger_treatment_add.designer_treatment_add_id` |  |
| `seq_tb_treatment_treatment_id` | `tb_treatment.treatment_id` |  |
| `seq_tb_treatment_treatment_class_id` | `tb_treatment_class.treatment_class_id` | 테이블명 오탈자 구간 존재 |
| `seq_tb_deeplink_deeplink_id` | `tb_deeplink.deeplink_id` |  |
| `seq_tb_shop_shop_id` | `tb_shop.shop_id` |  |
| `seq_tb_designer_shop_designer_shop_id` | `tb_designer_shop.designer_shop_id` |  |
| `seq_tb_appointment_appointment_id` | `tb_appointment.appointment_id` |  |
| `seq_tb_appointment_treatment_appointment_treatment_id` | `tb_appointment_treatment.appointment_treatment_id` |  |
| `seq_tb_chatroom_chatroom_id` | `tb_chatroom.chatroom_id` |  |
| `seq_tb_chatroom_member_chatroom_member_id` | `tb_chatroom_member.chatroom_member_id` |  |
| `seq_tb_chatroom_message_chat_message_id` | `tb_chatroom_message.chat_message_id` |  |
| `seq_tb_user_push_user_push_id` | `tb_user_push.user_push_id` |  |
| `seq_tb_admin_notification_admin_notification_id` | `tb_admin_notification.admin_notification_id` |  |
| `seq_tb_notification_notification_id` | `tb_notification.notification_id` |  |
| `seq_tb_notification_center_notification_center_id` | `tb_notification_center.notification_center_id` |  |
| `seq_tb_banner_banner_id` | `tb_banner.banner_id` |  |
| `seq_tb_offer_offer_id` | `tb_offer.offer_id` |  |
| `seq_tb_offer_treatment_offer_treatment_id` | `tb_offer_treatment.offer_treatment_id` |  |
| `seq_tb_offer_designer_offer_designer_id` | `tb_offer_designer.offer_designer_id` |  |
| `seq_tb_review_review_id` | `tb_review.review_id` |  |
| `seq_tb_designer_review_designer_review_id` | `tb_designer_review.designer_review_id` |  |
| `seq_tb_payment_payment_id` | `tb_payment.payment_id` |  |
| `seq_tb_recommand_recommand_id` | `tb_recommand.recommand_id` |  |
| `seq_tb_appointment_sign_appointment_sign_id` | `tb_appointment_sign.appointment_sign_id` |  |

---

## 10) 확인 필요(원본 DDL/스펙과 불일치 가능)

- `tb_configuration`: PK 부재
- `tb_treatment_class`: DDL 내 테이블명/드랍 대상 오탈자
- `tb_offer`, `tb_offer_designer`: `delete_id` 컬럼 누락(다른 테이블 관례와 불일치)
- 시퀀스가 text PK에 걸려 있는 케이스(정책 확인 필요)

