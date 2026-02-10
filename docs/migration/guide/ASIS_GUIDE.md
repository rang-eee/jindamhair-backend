# AS-IS Data Structure Guide

## 1. 개요

본 문서는 **Jindam Hair 프로젝트의 AS-IS 데이터 구조**를 정의한다.  
현재 운영 중인 **Firebase Firestore 실데이터**를 기준으로 생성된 스키마 문서를
사람이 이해하기 쉬운 형태로 해석·정리하는 것을 목적으로 한다.

- 대상 DB: Firebase Firestore
- 기준 시점: 문서 생성 시점의 실데이터
- 본 문서는 **변경(TO-BE)이나 개선안을 포함하지 않는다**

---

## 2. AS-IS 문서 구성

AS-IS 데이터 구조 문서는 다음 두 파일로 구성된다.

| 구분 | 파일 경로 | 설명 |
|---|---|---|
| 구조 정의 | `data/asis_schema.md` | Firestore 데이터를 샘플링하여 자동 생성된 스키마 |
| 작성 가이드 | `guide/ASIS_GUIDE.md` | 스키마 해석 및 표기 규칙 설명 |

---

## 3. asis_schema.md 생성 방법

```bash
cd docs/migration/script
node generate_schema_md.js
```

생성 결과 파일:

```
docs/migration/data/asis_schema.md
```

---

## 4. 스키마 표기 규칙

### 4.1 Field / Type 기본 표기

| 표기 | 의미 |
|---|---|
| String | 문자열 |
| Boolean | true / false |
| Int | 정수 |
| Double | 실수 |
| Timestamp | Firestore Timestamp |
| GeoPoint | 위도 / 경도 |
| DocumentReference | Firestore 문서 참조 |
| Map | Object 타입 |
| Array<T> | 배열 |
| <> | 타입을 명확히 알 수 없음 |

---

### 4.2 Array 표기 규칙

배열 타입은 **반드시 한 줄로만 표기**한다.

```
designerOpenDays | Array<Boolean>
```

---

### 4.3 동적 Key(uid / docId)

```
designerInfos.{uid}.name | String
designerInfos.{uid}.openYn | Boolean
```

---

## 5. 서브컬렉션 표기

```
users/{docId}/notificationCenters
```

---

## 6. AS-IS 문서 작성 원칙

- 현재 구조 그대로
- 중복 제거
- 추측 금지
