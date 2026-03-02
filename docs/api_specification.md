# 진담헤어 백엔드 API 명세서

> **최종 갱신일**: 2026-03-02  
> **Base URL**: `http://localhost:8080` (dev) / `http://api-jindamhair.velysound.synology.me` (prod)  
> **공통 응답 형식**: `ApiResultDto<T>`

---

## 📌 공통 응답 구조

### ApiResultDto\<T\>

```json
{
  "resultCode": 200,
  "resultMessage": "성공적으로 처리하였습니다.",
  "data": T
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `resultCode` | Integer | 200: 성공, 그 외: 실패 |
| `resultMessage` | String | 결과 메시지 |
| `data` | T | 응답 데이터 (실패 시 null) |

### PagingResponseDto\<T\> (페이징 응답)

페이징 엔드포인트의 `data`는 아래 구조입니다.

```json
{
  "totalElements": 100,
  "size": 10,
  "number": 0,
  "totalPages": 10,
  "content": [ T, T, ... ],
  "summary": null
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `totalElements` | Integer | 총 데이터 건수 |
| `size` | Integer | 페이지당 개수 |
| `number` | Integer | 현재 페이지 번호 (0-based) |
| `totalPages` | int | 총 페이지 수 |
| `content` | List\<T\> | 목록 데이터 |
| `summary` | Object | 합계/요약 데이터 (nullable) |

---

## 📌 공통 에러 응답

| HTTP Status | resultCode | 설명 |
|-------------|------------|------|
| 400 | 400 | 잘못된 요청 (파라미터 오류) |
| 401 | 401 | 인증 실패 |
| 403 | 403 | 권한 없음 |
| 404 | 404 | 리소스 없음 |
| 500 | 500 | 서버 내부 오류 |

---

## 1. 예약 (Appointment)

> **Base Path**: `/appointment`  
> **Tag**: 예약 관련 요청  
> **Controller**: `AppointmentController.java`

### 1-1. 예약 상세 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/appointment` |
| **설명** | 예약 ID로 상세 정보를 조회합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `appointmentId` | String | ✅ | 예약 ID |

**Response**: `ApiResultDto<AppointmentDetailResponseDto>`

<details>
<summary>AppointmentDetailResponseDto 주요 필드</summary>

| 필드 | 타입 | 설명 |
|------|------|------|
| `appointmentId` | String | 예약 ID |
| `customerUid` | String | 고객 UID |
| `designerUid` | String | 디자이너 UID |
| `shopId` | String | 헤어샵 ID |
| `appointmentStatusCode` | Object | 예약 상태 코드 (code/text/front) |
| `appointmentStartTypeCode` | Object | 시작 유형 코드 |
| `totalPrice` | String | 총 금액 |
| `appointmentPrice` | String | 예약 금액 |
| `startAt` | DateTime | 시술 시작 일시 |
| `endAt` | DateTime | 시술 종료 일시 |
| `paymentMethodCode` | Object | 결제 방법 코드 |
| `appointmentContent` | String | 예약 내용 |
| `cancelReason` | String | 취소 사유 |
| `reviewId` | String | 후기 ID |
| `customerUser*` | - | 고객 사용자 정보 (JOIN) |
| `designerUser*` | - | 디자이너 사용자 정보 (JOIN) |
| `appointmentMenuList` | List | 시술 항목 리스트 |

</details>

---

### 1-2. 고객 예약 목록 조회 (페이징)

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/appointment/customer` |
| **설명** | 고객 UID로 예약 목록을 조회합니다. 페이징을 지원합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 고객 UID |
| `page` | Integer | - | 페이지 번호 (default: 0) |
| `size` | Integer | - | 페이지 크기 (default: 10) |

**Response**: `ApiResultDto<PagingResponseDto<AppointmentDetailResponseDto>>`

---

### 1-3. 디자이너 예약 관리 목록 조회 (페이징)

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/appointment/designer` |
| **설명** | 디자이너 UID로 예약 목록을 조회합니다. 페이징을 지원합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 디자이너 UID |
| `page` | Integer | - | 페이지 번호 (default: 0) |
| `size` | Integer | - | 페이지 크기 (default: 10) |

**Response**: `ApiResultDto<PagingResponseDto<AppointmentDetailResponseDto>>`

---

### 1-4. 예약 생성

| 항목 | 값 |
|------|-----|
| **Method** | `POST` |
| **Path** | `/appointment` |
| **설명** | 예약 건을 생성합니다. |

**Request (JSON Body)**: `AppointmentInsertRequestDto`

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `customerUid` | String | ✅ | 고객 UID |
| `designerUid` | String | ✅ | 디자이너 UID |
| `shopId` | String | - | 헤어샵 ID |
| `appointmentStatusCode` | String | ✅ | 예약 상태 코드 |
| `startAt` | DateTime | ✅ | 시술 시작 일시 |
| `endAt` | DateTime | - | 시술 종료 일시 |
| `totalPrice` | String | - | 총 금액 |
| `appointmentPrice` | String | - | 예약 금액 |
| `paymentMethodCode` | String | - | 결제 방법 코드 |
| `appointmentContent` | String | - | 예약 내용 |

**Response**: `ApiResultDto<AppointmentDetailResponseDto>`

---

### 1-5. 예약 변경

| 항목 | 값 |
|------|-----|
| **Method** | `PATCH` |
| **Path** | `/appointment` |
| **설명** | 예약 건을 변경합니다. (알림 포함) |

**Request (JSON Body)**: `AppointmentUpdateRequestDto`

**Response**: `void` (resultCode로 성공 여부 판단)

---

### 1-6. 예약 확정

| 항목 | 값 |
|------|-----|
| **Method** | `PATCH` |
| **Path** | `/appointment/confirm` |
| **설명** | 예약 건을 완료(확정) 상태로 변경합니다. |

**Request (JSON Body)**: `AppointmentUpdateRequestDto`

**Response**: `void`

---

### 1-7. 예약 취소

| 항목 | 값 |
|------|-----|
| **Method** | `DELETE` |
| **Path** | `/appointment` |
| **설명** | 예약 건을 취소합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `appointmentId` | String | ✅ | 예약 ID |

**Response**: `void`

---

### 1-8. 서명 완료 처리

| 항목 | 값 |
|------|-----|
| **Method** | `PUT` |
| **Path** | `/appointment/sign` |
| **설명** | 예약 ID로 서명 데이터를 생성합니다. |

**Request (JSON Body)**: `AppointmentSignRequestDto`

**Response**: `void`

---

## 2. 채팅 (Chat)

> **Base Path**: `/chatRooms`  
> **Tag**: 채팅 관련 요청  
> **Controller**: `ChatContorller.java`

### 2-1. 채팅방 목록 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/chatRooms` |
| **설명** | 로그인 유저가 참여중인 채팅방 목록을 조회합니다. 멤버 정보, 최신 메시지, 안읽은 수 포함. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 로그인 사용자 UID |

**Response**: `ApiResultDto<List<ChatRoomMemberResponseDto>>`

<details>
<summary>ChatRoomMemberResponseDto 주요 필드</summary>

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | String | 채팅방 ID (chatroomId 와 동일) |
| `chatroomMemberId` | String | 채팅방 멤버 ID |
| `chatroomId` | String | 채팅방 ID |
| `uid` | String | 사용자 UID |
| `chatroomName` | String | 채팅방 명 |
| `lastReadAt` | DateTime | 최종 읽음 일시 |
| `createAt` | DateTime | 생성 일시 |
| `updateAt` | DateTime | 최종 수정 일시 (최신 메시지 기준) |
| `memberIds` | List\<String\> | 채팅방 멤버 UID 목록 |
| `memberInfos` | Map\<String, Object\> | 멤버 정보 {uid: {lastSeenDt, userName, ...}} |
| `title` | String | 채팅방 제목 (상대방 이름 기반) |
| `lastMessage` | String | 마지막 메시지 내용 |
| `lastMessageAt` | DateTime | 마지막 메시지 일시 |
| `lastMessageAuthorId` | String | 마지막 메시지 작성자 UID |
| `unreadCount` | Integer | 안읽은 메시지 수 |

</details>

---

### 2-2. 채팅방 목록 조회 (페이징)

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/chatRooms/paging` |
| **설명** | 로그인 유저가 참여중인 채팅방 목록을 페이징으로 조회합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 로그인 사용자 UID |
| `page` | Integer | - | 페이지 번호 |
| `size` | Integer | - | 페이지 크기 |

**Response**: `ApiResultDto<PagingResponseDto<ChatRoomMemberResponseDto>>`

---

## 3. 알림 (Notification)

> **Base Path**: `/notification`  
> **Tag**: 알림센터 관련 요청  
> **Controller**: `NotificationContorller.java`

### 3-1. 알림 센터 목록 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/notification/center` |
| **설명** | 수신자 UID로 알림 센터 목록을 조회합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `receiverUid` | String | ✅ | 수신자 UID |

**Response**: `ApiResultDto<List<NotificationCenterDetailResponseDto>>`

---

### 3-2. 알림 생성 ⚠️ 미구현

| 항목 | 값 |
|------|-----|
| **Method** | `POST` |
| **Path** | `/notification/center` |
| **상태** | ⚠️ **미구현** (return null) |

---

### 3-3. 알림 수정 ⚠️ 미구현

| 항목 | 값 |
|------|-----|
| **Method** | `PATCH` |
| **Path** | `/notification/center` |
| **상태** | ⚠️ **미구현** (return null) |

---

### 3-4. 알림 삭제 ⚠️ 미구현

| 항목 | 값 |
|------|-----|
| **Method** | `DELETE` |
| **Path** | `/notification/center` |
| **상태** | ⚠️ **미구현** (return null) |

---

## 4. 사용자 (User)

> **Base Path**: `/user`  
> **Tag**: 사용자 관련 요청  
> **Controller**: `UserController.java`

### 4-1. 사용자 상세 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/user` |
| **설명** | 사용자 상세정보를 조회합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 사용자 UID |

**Response**: `ApiResultDto<UserDetailResponseDto>`

---

### 4-2. 사용자 정보 생성

| 항목 | 값 |
|------|-----|
| **Method** | `POST` |
| **Path** | `/user` |
| **설명** | 사용자 정보를 입력합니다. |

**Request (JSON Body)**: `UserInsertRequestDto`

**Response**: `ApiResultDto<UserDetailResponseDto>`

---

### 4-3. 사용자 정보 수정

| 항목 | 값 |
|------|-----|
| **Method** | `PATCH` |
| **Path** | `/user` |
| **설명** | 사용자 상세정보를 수정합니다. |

**Request (JSON Body)**: `UserUpdateRequestDto`

**Response**: `ApiResultDto<UserDetailResponseDto>`

---

### 4-4. 디자이너 프로필 수정

| 항목 | 값 |
|------|-----|
| **Method** | `PUT` |
| **Path** | `/user` |
| **설명** | 디자이너 프로필을 수정합니다. (빈값은 null로 들어갑니다.) |

**Request (JSON Body)**: `UserUpdateRequestDto`

**Response**: `ApiResultDto<UserDetailResponseDto>`

---

### 4-5. 사용자 정보 삭제

| 항목 | 값 |
|------|-----|
| **Method** | `DELETE` |
| **Path** | `/user` |
| **설명** | 사용자 상세정보를 삭제 처리합니다. (soft delete) |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 사용자 UID |

**Response**: `ApiResultDto<UserDetailResponseDto>`

---

### 4-6. 사용자 로그인

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/user/login` |
| **설명** | 사용자 상세정보를 조회 후 최종 로그인 일시를 업데이트합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 사용자 UID |

**Response**: `ApiResultDto<UserDetailResponseDto>`

---

### 4-7. 디자이너 목록 조회 (페이징)

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/user/desinger-page` |
| **설명** | 디자이너 상세정보를 페이징으로 조회합니다. |

> ⚠️ URL에 오타 있음: `desinger` → `designer`

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `page` | Integer | - | 페이지 번호 |
| `size` | Integer | - | 페이지 크기 |
| `searchAll` | Boolean | - | `true` 시 페이징 무시, 전체 조회 |
| `designerApprStatusCode` | String (CodeEnum) | - | 디자이너 승인 상태 코드 (`unknown`/`preAuth`/`authComplete`/`authReject`/`authWait`). front 값(예: `DesignerAuthStatusType.authComplete`) 또는 code 값(예: `authComplete`) 전송 가능 |
| `designerWorkStatusCode` | String (CodeEnum) | - | 디자이너 근무 상태 코드 (`work`/`close`). front 값(예: `DesignerWorkStatusCode.work`) 또는 code 값(예: `work`) 전송 가능 |
| `searchText` | String | - | 닉네임 검색어 (ILIKE) |
| `userLat` | Double | - | 사용자 위도 (거리 계산/필터/정렬 용) |
| `userLng` | Double | - | 사용자 경도 (거리 계산/필터/정렬 용) |
| `maxDistanceKm` | Double | - | 최대 거리 km 필터 (`userLat`/`userLng` 필수) |

> **거리 기반 조회**: `userLat` + `userLng` 전달 시 Haversine 공식으로 `calcDistanceKm` 계산 후 거리순 정렬. `maxDistanceKm` 추가 시 해당 거리 이내만 필터.

**Response**: `ApiResultDto<PagingResponseDto<UserDetailResponseDto>>`

> `calcDistanceKm` (Double) 필드가 응답에 포함됩니다 (거리 계산 시).

---

### 4-8. 유저 즐겨찾기 목록 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/user/favorite` |
| **설명** | 유저 즐겨찾기 목록을 조회합니다. 페이징을 지원합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 사용자 UID |
| `page` | Integer | - | 페이지 번호 |
| `size` | Integer | - | 페이지 크기 |

**Response**: `ApiResultDto<PagingResponseDto<UserDetailResponseDto>>`

---

### 4-9. 유저 즐겨찾기 변경

| 항목 | 값 |
|------|-----|
| **Method** | `PATCH` |
| **Path** | `/user/favorite` |
| **설명** | 유저 즐겨찾기를 추가 및 취소합니다. |

**Request (JSON Body)**: `UserFavoriteInsertRequestDto`

**Response**: `void`

---

## 5. 헤어샵 (Shop)

> **Base Path**: `/shop`  
> **Tag**: 헤어샵 관련 요청  
> **Controller**: `ShopController.java`

### 5-1. 전체 헤어샵 목록 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/shop` |
| **설명** | 헤어샵 목록을 조회합니다. |

**Request**: 파라미터 없음

**Response**: `ApiResultDto<List<DesingerShopDetailResponseDto>>`

---

### 5-2. 헤어샵 생성

| 항목 | 값 |
|------|-----|
| **Method** | `POST` |
| **Path** | `/shop` |
| **설명** | 디자이너 헤어샵 정보를 입력합니다. |

**Request (JSON Body)**: `DesingerShopInsertRequestDto`

**Response**: `ApiResultDto<DesingerShopDetailResponseDto>`

---

### 5-3. 헤어샵 수정

| 항목 | 값 |
|------|-----|
| **Method** | `PATCH` |
| **Path** | `/shop` |
| **설명** | UID에 해당하는 디자이너 헤어샵을 수정합니다. |

**Request (JSON Body)**: `DesingerShopUpdateRequestDto`

**Response**: `ApiResultDto<DesingerShopDetailResponseDto>`

---

### 5-4. 헤어샵 삭제

| 항목 | 값 |
|------|-----|
| **Method** | `DELETE` |
| **Path** | `/shop` |
| **설명** | UID에 해당하는 디자이너 헤어샵을 삭제합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `uid` | String | ✅ | 디자이너 UID |
| `shopId` | String | ✅ | 헤어샵 ID |

**Response**: `ApiResultDto<DesingerShopDetailResponseDto>`

---

## 6. 시술 (Treatment)

> **Base Path**: `/treatment`  
> **Tag**: 시술 관련 요청  
> **Controller**: `TreatmentController.java`

> ⚠️ 이 컨트롤러는 `ApiResultDto` 래핑 없이 raw 타입을 직접 반환합니다.

### 6-1. 디자이너 시술 메뉴 목록 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/treatment` |
| **설명** | 디자이너 ID로 시술 메뉴 분류 목록을 조회합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `designerUid` | String | ✅ | 디자이너 UID |

**Response**: `List<TreatmentClassificationResponseDto>` ⚠️ ApiResultDto 미래핑

---

### 6-2. 디자이너 시술 상세 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/treatment/detail` |
| **설명** | 시술 추가 리스트를 조회합니다. 추가여부 N일 시 null 반환. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `designerUid` | String | ✅ | 디자이너 UID |

**Response**: `List<TreatmentResponseDto>` ⚠️ ApiResultDto 미래핑

---

### 6-3. 디자이너 시술 수정

| 항목 | 값 |
|------|-----|
| **Method** | `PATCH` |
| **Path** | `/treatment/detail` |
| **설명** | 디자이너 아이디로 시술 정보를 수정합니다. (삭제 요청 포함) |

**Request (JSON Body)**: `TreatmentUpdateRequestDto`

**Response**: `int` ⚠️ ApiResultDto 미래핑

---

## 7. 배너 (Banner)

> **Base Path**: `/banner`  
> **Tag**: 배너 관련 요청  
> **Controller**: `BannerController.java`

### 7-1. 배너 목록 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/banner` |
| **설명** | 위치에 따른 배너 목록을 조회합니다. |

**Request (Query Params)**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `bannerDisplayTargetCode` | String | - | 배너 노출 위치 코드 |

**Response**: `ApiResultDto<List<BannerDetailResponseDto>>`

---

## 8. 설정 (Configuration)

> **Base Path**: `/configuration`  
> **Tag**: Setting api  
> **Controller**: `SettingController.java`

### 8-1. 앱 빌드 버전 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/configuration` |
| **설명** | 앱 빌드 버전을 조회합니다. |

**Request**: 파라미터 없음

**Response**: `ApiResultDto<SettingDetailResponseDto>`

---

## 9. 예제 (Example)

> **Base Path**: `/v1/api/example`  
> **Tag**: [공통] 예제 관련 처리  
> **Controller**: `ExampleController.java`

### 9-1. 전체 목록 페이징 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/v1/api/example/list-page` |
| **설명** | 페이지 데이터로 예제 항목을 조회합니다. |

**Response**: `ApiResultDto<PagingResponseDto<ExampleDetailResponseDto>>`

---

### 9-2. 전체 목록 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/v1/api/example/list` |
| **설명** | 모든 예제 항목을 조회합니다. |

**Response**: `ApiResultDto<List<ExampleDetailResponseDto>>`

---

### 9-3. 단일 항목 조회

| 항목 | 값 |
|------|-----|
| **Method** | `GET` |
| **Path** | `/v1/api/example` |

**Response**: `ApiResultDto<ExampleDetailResponseDto>`

---

### 9-4. 항목 생성

| 항목 | 값 |
|------|-----|
| **Method** | `POST` |
| **Path** | `/v1/api/example` |

**Response**: `ApiResultDto<ExampleDetailResponseDto>`

---

### 9-5. 항목 수정

| 항목 | 값 |
|------|-----|
| **Method** | `PUT` |
| **Path** | `/v1/api/example` |

**Response**: `ApiResultDto<ExampleDetailResponseDto>`

---

### 9-6. 항목 삭제

| 항목 | 값 |
|------|-----|
| **Method** | `DELETE` |
| **Path** | `/v1/api/example` |

**Response**: `ApiResultDto<ExampleDetailResponseDto>`

---

## 📊 전체 엔드포인트 요약

| 도메인 | GET | POST | PATCH | PUT | DELETE | 합계 |
|--------|-----|------|-------|-----|--------|------|
| Appointment | 3 | 1 | 2 | 1 | 1 | **8** |
| Chat | 2 | - | - | - | - | **2** |
| Notification | 1 | 1⚠️ | 1⚠️ | - | 1⚠️ | **4** |
| User | 4 | 1 | 2 | 1 | 1 | **9** |
| Shop | 1 | 1 | 1 | - | 1 | **4** |
| Treatment | 2 | - | 1 | - | - | **3** |
| Banner | 1 | - | - | - | - | **1** |
| Configuration | 1 | - | - | - | - | **1** |
| Example | 3 | 1 | - | 1 | 1 | **6** |
| **합계** | **18** | **5** | **7** | **3** | **5** | **38** |

> ⚠️ = 미구현 (return null)

---

## 📋 알려진 이슈

| # | 항목 | 설명 |
|---|------|------|
| 1 | URL 오타 | `/user/desinger-page` → `/user/designer-page` |
| 2 | 패키지 오타 | `contoller` 패키지명 (chat, notification, example) |
| 3 | DTO 오타 | `DesingerShop*` → `DesignerShop*` |
| 4 | 응답 일관성 | TreatmentController만 `ApiResultDto` 미래핑 |
| 5 | 미구현 API | Notification INSERT/UPDATE/DELETE → `return null` |
| 6 | 미구현 컨트롤러 | Offer, Review, Payment, Statistics 컨트롤러 없음 (Flutter `Apis`에는 경로 정의됨) |
