# 데이터 이관 전략

## 1. Firestore → PostgreSQL 이관 (Node.js 사용)

### ▸ 기본 전략
- **Firestore 구조를 그대로 PostgreSQL로 이관**
- PostgreSQL 내 테이블은 `fs_~` prefix 사용

---

### ▸ PostgreSQL DDL 생성
- Firestore 구조 기반 테이블 생성
- 파일명:
  - `firestore_to_postgre_ddl.sql`

---

### ▸ Node 패키지 설치

```bash
$ npm init -y
$ npm i firebase-admin pg
```

---

### ▸ Firestore 권한 파일 다운로드

1. **Firebase 콘솔** 접속  
2. 프로젝트 선택  
3. 좌측 상단 ⚙️ **프로젝트 설정**  
4. **서비스 계정** 탭 이동  
5. **새 비공개 키 생성 (Generate new private key)**  
   → JSON 파일 다운로드  
   → 해당 파일이 `serviceAccount.json`

> ⚠️ **주의**
> - 다운로드한 JSON 파일은 **절대 GitHub에 업로드 금지**
> - 키 유출 위험 있음

---

### ▸ 이관 스크립트 작성
- 파일명:
  - `migrate.js`

---

### ▸ 환경변수 등록

```bash
export PG_URL='postgresql://jindamhair:jindamhair1!@velysound.synology.me:5432/jindamhair'

export GOOGLE_APPLICATION_CREDENTIALS='/Users/bbamkeylee/dev/mig/jindamhair-serverAccount.json'
```

---

## 2. PostgreSQL → PostgreSQL 구조 변환
- Firestore 구조(`fs_~`) 기준
- 실제 서비스용 테이블 구조에 맞게
- **PostgreSQL 프로시저 작성**

---

## 3. 데이터 마이그레이션 실행
- Node 이관 스크립트 실행
- PostgreSQL 프로시저 실행
- 데이터 검증

### ▸ 실행 전 필수: 기존 데이터 전체 삭제
모든 마이그레이션은 **기존 테이블 데이터를 전부 삭제(초기화)한 후** 진행한다.

- `migrate.js` 실행 시 **모든 `fs_*` 테이블을 TRUNCATE** 후 적재한다.
- `tb_*` 이관 프로시저 실행 전에는 **해당 `tb_*` 테이블을 TRUNCATE** 한다.

> 주의: 운영 환경에서 실행 시 반드시 백업 후 진행
