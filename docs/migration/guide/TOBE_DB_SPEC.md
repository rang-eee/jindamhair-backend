# TO-BE Database Specification (PostgreSQL)

## 1. 개요
본 문서는 **Firestore → PostgreSQL 마이그레이션 이후 사용될 TO-BE 데이터베이스 스펙**을 정의한다.  
AS-IS Firestore 구조를 기반으로 정규화된 RDB 테이블 및 시퀀스 정의를 포함한다.

- DBMS: PostgreSQL
- Schema: `jindamhair`
- 목적: 운영 서비스용 정규 테이블 정의

---

## 2. 테이블 공통 규칙

- 기본 키: 각 테이블별 ID (text)
- 논리 삭제 컬럼 사용
  - `delete_yn CHAR(1) DEFAULT 'N'`
  - `delete_at TIMESTAMP`
  - `delete_id TEXT`
- 감사 컬럼
  - `create_at TIMESTAMP DEFAULT now()`
  - `create_id TEXT`
  - `update_at TIMESTAMP`
  - `update_id TEXT`

---

## 3. 주요 테이블 목록

### 3.1 사용자 / 계정

- `tb_user` : 사용자
- `tb_designer_shop` : 디자이너-샵 관계
- `tb_designer_off` : 디자이너 휴무

---

### 3.2 시술 / 제안

- `tb_treatment` : 시술
- `tb_treatment_class` : 시술 분류
- `tb_desinger_treatment` : 디자이너 시술
- `tb_desinger_treatment_add` : 디자이너 시술 추가 옵션
- `tb_offer` : 제안
- `tb_offer_treatment` : 제안 시술
- `tb_offer_designer` : 제안 디자이너

---

### 3.3 예약 / 결제

- `tb_appointment` : 예약
- `tb_appointment_treatment` : 예약 시술
- `tb_appointment_sign` : 예약 서명
- `tb_payment` : 결제

---

### 3.4 알림 / 메시지

- `tb_notification` : 알림
- `tb_notification_center` : 알림 센터
- `tb_user_push` : 사용자 푸시
- `tb_admin_notification` : 관리자 알림

---

### 3.5 채팅

- `tb_chatroom` : 채팅방
- `tb_chatroom_member` : 채팅방 멤버
- `tb_chatroom_message` : 채팅 메시지

---

### 3.6 콘텐츠 / 기타

- `tb_banner` : 배너
- `tb_review` : 후기
- `tb_designer_review` : 디자이너 후기 집계
- `tb_recommand` : 추천
- `tb_shop` : 헤어샵
- `tb_file` : 파일
- `tb_log_error` : 에러 로그
- `tb_configuration` : 시스템 설정
- `tb_deeplink` : 딥링크

---

## 4. 시퀀스 정책

- 모든 ID는 **text 타입**이나,
  내부적으로는 PostgreSQL SEQUENCE를 사용하여 생성 가능
- 시퀀스 명명 규칙:
  ```
  seq_{table_name}_{pk_column}
  ```

### 예시
```sql
CREATE SEQUENCE jindamhair.seq_tb_deeplink_deeplink_id;
CREATE SEQUENCE jindamhair.seq_tb_user_uid;
CREATE SEQUENCE jindamhair.seq_tb_appointment_appointment_id;
```

---

## 5. 마이그레이션 연계

- Firestore Raw 데이터 → `fs_*` 테이블
- `fs_*` → `tb_*` 변환은 **개별 프로시저 단위**로 수행
- 본 스펙은 `result/procedures/*.sql` 프로시저의 기준 문서로 사용된다.

---

## 6. 관리 원칙

- TO-BE 스펙 변경 시 반드시 버전 관리
- AS-IS 문서는 수정하지 않음
- 컬럼 삭제/변경은 Migration Script로만 처리

---

## 7. 다음 단계

- 테이블별 컬럼 매핑 문서 작성
- 프로시저 실행 순서 정의
- 데이터 검증 SQL 정의
