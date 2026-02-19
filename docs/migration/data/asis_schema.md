# Firestore DB Structure

- GeneratedAt: `2026-02-10T14:05:44.337Z`
- SampleDocsPerCollection: `200`
- MaxDepth(dot-notation): `2`

> Types are inferred by sampling documents.
> Optional/mixed fields appear as unions (e.g. String | null).
> Dynamic map keys like uid/docId are collapsed to `{uid}` to avoid exploding the schema.

## Collection: alerts

- Path: `alerts`

| Field | Type |
|---|---|
| `appointmentAt` | null |
| `createAt` | Timestamp |
| `id` | String |
| `message` | String |
| `sendAt` | Timestamp |
| `sendMethodType` | String |
| `sendMethodTypeName` | String |
| `sendPeriodType` | String |
| `sendPeriodTypeName` | String |
| `sendUserType` | String |
| `sendUserTypeName` | String |
| `successYn` | Boolean | null |
| `targetUserType` | String |
| `targetUserTypeName` | String |
| `title` | String |


## Collection: appointments

- Path: `appointments`

| Field | Type |
|---|---|
| `addHairPrice` | null |
| `appointmentStatusType` | String |
| `appointmentStatusTypeName` | String |
| `beginMethodType` | String | null |
| `beginMethodTypeName` | String | null |
| `cancelReason` | String | null |
| `createAt` | Timestamp |
| `designerImageUrl` | String | null |
| `designerModel` | Map | null |
| `designerModel.ageType` | String |
| `designerModel.ageTypeName` | String |
| `designerModel.allowNoticeEventNotification` | Boolean |
| `designerModel.allowPushNotification` | Boolean |
| `designerModel.birth` | String |
| `designerModel.blockIds` | Array |
| `designerModel.blockIds[]` | Element<> |
| `designerModel.createAt` | Timestamp |
| `designerModel.designerAllCloseTime` | Array |
| `designerModel.designerAllCloseTime[]` | Element<String> | Element<> |
| `designerModel.designerAuthStatus` | String |
| `designerModel.designerAuthStatusType` | String |
| `designerModel.designerAuthStatusTypeName` | String |
| `designerModel.designerAutoConfirmAppointment` | Boolean |
| `designerModel.designerCloseTime` | Array |
| `designerModel.designerCloseTime[]` | Element<String> |
| `designerModel.designerDetailDynamicLinkUrl` | String |
| `designerModel.designerInfo` | String |
| `designerModel.designerIsWork` | Boolean |
| `designerModel.designerLicenseImageUrl` | String |
| `designerModel.designerOpenDays` | Array |
| `designerModel.designerOpenDays[]` | Element<Boolean> |
| `designerModel.designerOpenTime` | Array |
| `designerModel.designerOpenTime[]` | Element<String> |
| `designerModel.designerPhotos` | Array |
| `designerModel.designerPhotos[]` | Element<String> | Element<> |
| `designerModel.designerTags` | String |
| `designerModel.email` | String |
| `designerModel.favoriteId` | String |
| `designerModel.favoriteIds` | Array |
| `designerModel.favoriteIds[]` | Element<> | Element<String> |
| `designerModel.genderType` | String |
| `designerModel.genderTypeName` | String |
| `designerModel.imageUrl` | String |
| `designerModel.isAgreePrivacy` | Boolean |
| `designerModel.isAgreeTerms` | Boolean |
| `designerModel.isNotificationAdvertisement` | Boolean |
| `designerModel.isNotificationAdvertisementAt` | null |
| `designerModel.isNotificationAll` | Boolean |
| `designerModel.isNotificationAllAt` | Timestamp |
| `designerModel.isNotificationAppointment` | Boolean |
| `designerModel.isNotificationAppointmentAt` | Timestamp |
| `designerModel.isNotificationChat` | Boolean |
| `designerModel.isNotificationChatAt` | null |
| `designerModel.isNotificationNoticeAt` | null |
| `designerModel.isNotificationOffer` | Boolean |
| `designerModel.isNotificationOfferAt` | null |
| `designerModel.lastLoginAt` | Timestamp |
| `designerModel.locationAddress` | String |
| `designerModel.locationDistance` | Int | Double |
| `designerModel.locationLatitude` | Double |
| `designerModel.locationLongitude` | Double |
| `designerModel.name` | String |
| `designerModel.nickname` | String |
| `designerModel.phoneNum` | String |
| `designerModel.pushToken` | String |
| `designerModel.reivewCount` | Map |
| `designerModel.reviewCount` | Map |
| `designerModel.signUpMethod` | String |
| `designerModel.signUpMethodType` | String |
| `designerModel.signUpMethodTypeName` | String |
| `designerModel.storeAddress` | String |
| `designerModel.storeId` | String |
| `designerModel.storeName` | String |
| `designerModel.storePhoneNum` | String |
| `designerModel.uid` | String |
| `designerModel.userStatusType` | String |
| `designerModel.userStatusTypeName` | String |
| `designerModel.userType` | String |
| `designerModel.userTypeName` | String |
| `designerName` | String |
| `designerUid` | String |
| `endAt` | Timestamp |
| `hairTitle` | String |
| `id` | String |
| `isModifyOfAppointment` | Boolean |
| `menus` | Array | null |
| `menus[]` | Element<> |
| `paymentKey` | null |
| `paymentMethodType` | String | null |
| `paymentMethodTypeName` | String | null |
| `price` | String |
| `reviewId` | null |
| `startAt` | Timestamp |
| `storeId` | String |
| `storeName` | String |
| `timer` | String |
| `updateAt` | Timestamp |
| `userName` | String |
| `userPhoneNum` | String |
| `userUid` | String |


## Collection: banners

- Path: `banners`

| Field | Type |
|---|---|
| `bannerType` | String |
| `bannerTypeName` | String |
| `content` | String |
| `createAt` | Timestamp |
| `displayEndAt` | Timestamp |
| `displayPositionType` | String |
| `displayPositionTypeName` | String |
| `displayStartAt` | Timestamp |
| `displayTargetUserType` | String |
| `displayTargetUserTypeName` | String |
| `displayTimeType` | String |
| `displayTimeTypeName` | String |
| `displayType` | String |
| `displayTypeName` | String |
| `iconType` | String |
| `iconTypeName` | String |
| `id` | String |
| `layerHeight` | Int |
| `sort` | Int |
| `title` | String |
| `updateAt` | Timestamp |


## Collection: chatRooms

- Path: `chatRooms`

| Field | Type |
|---|---|
| `createAt` | Timestamp |
| `id` | String |
| `lastMessage` | String | null |
| `memberIds` | Array |
| `memberIds[]` | Element<String> |
| `memberInfos` | Map |
| `memberInfos.{uid}.lastMessage` | String |
| `memberInfos.{uid}.lastSeenDt` | Timestamp |
| `memberInfos.{uid}.title` | String |
| `memberInfos.{uid}.uid` | String |
| `memberRecentSeenById` | Map |
| `memberRecentSeenById.{uid}` | Timestamp |
| `membersModel` | null |
| `membersRaw` | Map |
| `membersRaw.{uid}.id` | String |
| `membersRaw.{uid}.imageBlurHash` | String | null |
| `membersRaw.{uid}.imageUrl` | String | null |
| `membersRaw.{uid}.nickname` | String |
| `receiveId` | String |
| `sendId` | String |
| `title` | String | null |
| `updateAt` | Timestamp |


## Collection: configuration

- Path: `configuration`

| Field | Type |
|---|---|
| `allow_minmum_build_number` | String |
| `allowMinmumBuildNumber` | String |
| `aosAllowMinmumBuildNumber` | String |
| `aosLastestVersion` | String |
| `iosAllowMinmumBuildNumber` | String |
| `iosLastestVersion` | String |
| `lastest_version` | String |
| `lastestVersion` | String |


## Collection: dynamicLinks

- Path: `dynamicLinks`

| Field | Type |
|---|---|
| `createAt` | Timestamp |
| `email` | String |
| `id` | String |
| `link` | String |
| `linkKey` | String |
| `updateAt` | Timestamp |


## Collection: notifications

- Path: `notifications`

| Field | Type |
|---|---|
| `createAt` | Timestamp |
| `eventWhenClick` | String |
| `id` | String |
| `message` | String |
| `payload` | Map |
| `receiverUid` | String |
| `sendAt` | Timestamp |
| `title` | String |
| `topic` | String |


## Collection: offers

- Path: `offers`

| Field | Type |
|---|---|
| `createAt` | Timestamp |
| `designerIds` | Array | null |
| `designerIds[]` | Element<String> |
| `designerInfos` | Map | null |
| `designerInfos.{uid}.status` | String |
| `designers` | null |
| `distance` | null |
| `id` | String |
| `levelCodes1` | Array |
| `levelCodes1[]` | Element<String> |
| `levelCodes2` | Array |
| `levelCodes2[]` | Element<String> |
| `levelCodes3` | null |
| `levelTitles1` | Array |
| `levelTitles1[]` | Element<String> |
| `levelTitles2` | Array |
| `levelTitles2[]` | Element<String> |
| `levelTitles3` | null |
| `offerAt` | Timestamp |
| `offerLocationAddress` | null |
| `offerLocationDistance` | String | Int |
| `offerLocationLatitude` | String | Double |
| `offerLocationLongitude` | String | Double |
| `offerMemo` | String |
| `offerStatusType` | String |
| `offerStatusTypeName` | String |
| `offerUid` | String |
| `offerUserModel` | Map |
| `offerUserModel.ageType` | String |
| `offerUserModel.ageTypeName` | String |
| `offerUserModel.allowNoticeEventNotification` | Boolean |
| `offerUserModel.allowPushNotification` | Boolean |
| `offerUserModel.birth` | String |
| `offerUserModel.blockIds` | Array |
| `offerUserModel.blockIds[]` | Element<> |
| `offerUserModel.createAt` | Timestamp |
| `offerUserModel.designerAllCloseTime` | Array |
| `offerUserModel.designerAllCloseTime[]` | Element<> |
| `offerUserModel.designerAuthStatusType` | String |
| `offerUserModel.designerAuthStatusTypeName` | String |
| `offerUserModel.designerAutoConfirmAppointment` | Boolean |
| `offerUserModel.designerCloseTime` | Array |
| `offerUserModel.designerCloseTime[]` | Element<> | Element<String> |
| `offerUserModel.designerDetailDynamicLinkUrl` | String |
| `offerUserModel.designerInfo` | String |
| `offerUserModel.designerIsWork` | Boolean |
| `offerUserModel.designerLicenseImageUrl` | String |
| `offerUserModel.designerOpenDays` | Array |
| `offerUserModel.designerOpenDays[]` | Element<Boolean> |
| `offerUserModel.designerOpenTime` | Array |
| `offerUserModel.designerOpenTime[]` | Element<> | Element<String> |
| `offerUserModel.designerPhotos` | Array |
| `offerUserModel.designerPhotos[]` | Element<> |
| `offerUserModel.designerTags` | String |
| `offerUserModel.email` | String |
| `offerUserModel.favoriteId` | String |
| `offerUserModel.favoriteIds` | Array |
| `offerUserModel.favoriteIds[]` | Element<> | Element<String> |
| `offerUserModel.genderType` | String |
| `offerUserModel.genderTypeName` | String |
| `offerUserModel.imageUrl` | String |
| `offerUserModel.isAgreePrivacy` | Boolean |
| `offerUserModel.isAgreeTerms` | Boolean |
| `offerUserModel.isNotificationAdvertisement` | Boolean |
| `offerUserModel.isNotificationAdvertisementAt` | Timestamp | null |
| `offerUserModel.isNotificationAll` | Boolean |
| `offerUserModel.isNotificationAllAt` | Timestamp | null |
| `offerUserModel.isNotificationAppointment` | Boolean |
| `offerUserModel.isNotificationAppointmentAt` | Timestamp | null |
| `offerUserModel.isNotificationChat` | Boolean |
| `offerUserModel.isNotificationChatAt` | Timestamp | null |
| `offerUserModel.isNotificationNoticeAt` | Timestamp | null |
| `offerUserModel.isNotificationOffer` | Boolean |
| `offerUserModel.isNotificationOfferAt` | Timestamp | null |
| `offerUserModel.lastLoginAt` | Timestamp |
| `offerUserModel.locationAddress` | String |
| `offerUserModel.locationDistance` | Int | Double |
| `offerUserModel.locationLatitude` | Double |
| `offerUserModel.locationLongitude` | Double |
| `offerUserModel.name` | String |
| `offerUserModel.nickname` | String |
| `offerUserModel.phoneNum` | String |
| `offerUserModel.pushToken` | String |
| `offerUserModel.reivewCount` | Map |
| `offerUserModel.reviewCount` | Map |
| `offerUserModel.signUpMethodType` | String |
| `offerUserModel.signUpMethodTypeName` | String |
| `offerUserModel.storeAddress` | String |
| `offerUserModel.storeId` | String |
| `offerUserModel.storeName` | String |
| `offerUserModel.storePhoneNum` | String |
| `offerUserModel.uid` | String |
| `offerUserModel.userStatusType` | String |
| `offerUserModel.userStatusTypeName` | String |
| `offerUserModel.userType` | String |
| `offerUserModel.userTypeName` | String |
| `price` | Int |
| `updateAt` | Timestamp | null |


## Collection: payments

- Path: `payments`

| Field | Type |
|---|---|
| `amount` | Int |
| `createAt` | Timestamp |
| `id` | String |
| `orderId` | String |
| `paymentKey` | String |
| `paymentType` | String |


## Collection: pushes

- Path: `pushes`

| Field | Type |
|---|---|
| `appointmentId` | String |
| `createAt` | Timestamp |
| `eventWhenClick` | String |
| `id` | String |
| `isSend` | Boolean |
| `message` | String |
| `receiveId` | String |
| `sendAt` | Timestamp |
| `sendedAt` | Timestamp |
| `title` | String |


## Collection: reservations

- Path: `reservations`

| Field | Type |
|---|---|
| `addHairOption` | String | null |
| `addHairPrice` | null |
| `createAt` | Timestamp | null |
| `designerImageUrl` | String | null |
| `designerModel` | Map | null |
| `designerModel.allowNoticeEventNotification` | Boolean |
| `designerModel.allowPushNotification` | Boolean |
| `designerModel.birth` | String |
| `designerModel.blockIds` | Array |
| `designerModel.blockIds[]` | Element<> |
| `designerModel.createAt` | Timestamp |
| `designerModel.designerAuthStatus` | String |
| `designerModel.designerCloseTime` | Array |
| `designerModel.designerCloseTime[]` | Element<String> |
| `designerModel.designerInfo` | String |
| `designerModel.designerIsWork` | Boolean |
| `designerModel.designerLicenseImageUrl` | String |
| `designerModel.designerOpenDays` | Array |
| `designerModel.designerOpenDays[]` | Element<Boolean> |
| `designerModel.designerOpenTime` | Array |
| `designerModel.designerOpenTime[]` | Element<String> |
| `designerModel.designerPhotos` | Array |
| `designerModel.designerPhotos[]` | Element<> | Element<String> |
| `designerModel.designerTags` | String |
| `designerModel.email` | String |
| `designerModel.favoriteId` | String |
| `designerModel.favoriteIds` | Array |
| `designerModel.favoriteIds[]` | Element<> |
| `designerModel.genderName` | String |
| `designerModel.genderType` | String |
| `designerModel.imageUrl` | String |
| `designerModel.locationAddress` | String |
| `designerModel.locationDistance` | Int | Double |
| `designerModel.locationLatitude` | Double |
| `designerModel.locationLongitude` | Double |
| `designerModel.name` | String |
| `designerModel.nickname` | String |
| `designerModel.phoneNum` | String |
| `designerModel.pushToken` | String |
| `designerModel.signUpMethod` | String |
| `designerModel.storeAddress` | String |
| `designerModel.storeId` | String |
| `designerModel.storeName` | String |
| `designerModel.storePhoneNum` | String |
| `designerModel.uid` | String |
| `designerModel.userType` | String |
| `designerName` | String |
| `designerUid` | String |
| `endAt` | Timestamp |
| `hairCutType` | String | null |
| `hairTitle` | String |
| `id` | String |
| `imageUrl` | String | null |
| `isClosedToday` | Boolean |
| `isFinished` | Boolean |
| `isRead` | Boolean |
| `menuModel` | Map | null |
| `menuModel.chestPrice` | String |
| `menuModel.chinPrice` | String |
| `menuModel.createAt` | Timestamp |
| `menuModel.designerId` | String |
| `menuModel.hairAddTitle` | String |
| `menuModel.hairGenderType` | String |
| `menuModel.hairImageUrl` | Array |
| `menuModel.hairImageUrl[]` | Element<> | Element<String> |
| `menuModel.hairInfo` | String |
| `menuModel.hairTime` | String |
| `menuModel.id` | String |
| `menuModel.isAddPrice` | Boolean |
| `menuModel.isOpenMenu` | Boolean |
| `menuModel.isSalePrice` | Boolean |
| `menuModel.order` | Int |
| `menuModel.percent` | String |
| `menuModel.price` | String |
| `menuModel.salePrice` | String |
| `menuModel.shoulderPrice` | String |
| `menuModel.title` | String |
| `menuModel.totalPrice` | String |
| `menuModel.waistPrice` | String |
| `modifyOfReservation` | Boolean |
| `paymentMethod` | String | null |
| `price` | String |
| `reservationStatus` | Boolean |
| `reservationType` | String | null |
| `selectHairAddType` | String | null |
| `startAt` | Timestamp |
| `storeName` | String |
| `timer` | String |
| `userName` | String |
| `userPhoneNum` | String |
| `userUid` | String |


## Collection: reviews

- Path: `reviews`

| Field | Type |
|---|---|
| `appointmentId` | String |
| `createAt` | Timestamp |
| `customerId` | String |
| `designerId` | String |
| `id` | String |
| `reviewContent` | String |
| `reviewType` | Array |
| `reviewType[]` | Element<> | Element<String> |
| `updateAt` | null |


## Collection: statistics

- Path: `statistics`

| Field | Type |
|---|---|
| `createAt` | Timestamp |
| `designerRecommendCount` | Int |
| `designerUid` | String |
| `id` | String |
| `joinUserUids` | Array |
| `joinUserUids[]` | Element<String> |
| `updateAt` | Timestamp |


## Collection: stores

- Path: `stores`

| Field | Type |
|---|---|
| `address` | String |
| `addressDetail` | String | null |
| `contactNumber` | String |
| `createAt` | Timestamp |
| `description` | String |
| `gpsX` | Double |
| `gpsY` | Double |
| `id` | String |
| `isRepresentative` | Boolean | null |
| `phoneNum` | String |
| `postCode` | String |
| `storeAddType` | null |
| `storeAddTypeName` | null |
| `storeStatusType` | String |
| `storeStatusTypeName` | String |
| `title` | String |


## Collection: treatmentClassfications

- Path: `treatmentClassfications`

| Field | Type |
|---|---|
| `code` | String |
| `createAt` | Timestamp |
| `id` | String |
| `level` | Int |
| `levelCode1` | String |
| `levelCode2` | String |
| `levelCode3` | String |
| `levelTitle1` | String |
| `levelTitle2` | String |
| `levelTitle3` | String |
| `offerMinPrice` | String |
| `sort` | Int |
| `title` | String |
| `uid` | String |
| `updateAt` | Timestamp |
| `useYn` | Boolean |


## Collection: treatments

- Path: `treatments`

| Field | Type |
|---|---|
| `code` | String |
| `createAt` | Timestamp |
| `id` | String |
| `level` | Int |
| `offerMinPrice` | String | null |
| `sort` | Int |
| `title` | String |
| `uid` | String |
| `updateAt` | Timestamp |
| `useYn` | Boolean |


## Collection: users

- Path: `users`

| Field | Type |
|---|---|
| ` chargeHistory` | Array |
| ` chargeHistory[]` | Element<> |
| `accountInfo` | null |
| `address` | String |
| `ageType` | String | null |
| `ageTypeName` | String | null |
| `allowActivityNotification` | Boolean |
| `allowNoticeEventNotification` | Boolean |
| `allowPushNotification` | Boolean |
| `birth` | String |
| `blockIds` | Array | null |
| `blockIds[]` | Element<> |
| `closeTime` | Array |
| `closeTime[]` | Element<> | Element<String> |
| `createAt` | Timestamp |
| `designerAccountBrandType` | null |
| `designerAccountBrandTypeName` | null |
| `designerAccountNumber` | null |
| `designerAllCloseTime` | Array | null |
| `designerAllCloseTime[]` | Element<> | Element<String> |
| `designerAuthStatus` | String | null |
| `designerAuthStatusType` | String |
| `designerAuthStatusTypeName` | String |
| `designerAutoConfirmAppointment` | Boolean | null |
| `designerCloseTime` | Array |
| `designerCloseTime[]` | Element<String> | Element<> |
| `designerDetailDynamicLinkUrl` | String | null |
| `designerInfo` | String | null |
| `designerIsWork` | Boolean | null |
| `designerLicenseImageUrl` | String | null |
| `designerOpenDays` | Array |
| `designerOpenDays[]` | Element<Boolean> |
| `designerOpenTime` | Array |
| `designerOpenTime[]` | Element<String> | Element<> |
| `designerPhotos` | Array | null |
| `designerPhotos[]` | Element<String> | Element<> |
| `designerRestTimes` | Map |
| `designerTags` | String | null |
| `distance` | Int | Double |
| `email` | String |
| `favoriteId` | String |
| `favoriteIds` | Array | null |
| `favoriteIds[]` | Element<> | Element<String> |
| `genderName` | String |
| `genderType` | String |
| `genderTypeName` | String | null |
| `hairImages` | Array |
| `hairImages[]` | Element<> |
| `hairTitle` | null |
| `id` | String |
| `imageUrl` | String |
| `isAgreePrivacy` | Boolean | null |
| `isAgreeTerms` | Boolean | null |
| `isLastReadMessage` | Boolean |
| `isNotificationAdvertisement` | Boolean |
| `isNotificationAdvertisementAt` | Timestamp | null |
| `isNotificationAll` | Boolean |
| `isNotificationAllAt` | Timestamp | null |
| `isNotificationAppointment` | Boolean |
| `isNotificationAppointmentAt` | Timestamp | null |
| `isNotificationChat` | Boolean |
| `isNotificationChatAt` | Timestamp | null |
| `isNotificationNotice` | Boolean |
| `isNotificationNoticeAt` | Timestamp | null |
| `isNotificationOffer` | Boolean |
| `isNotificationOfferAt` | Timestamp | null |
| `isWork` | Boolean | null |
| `languageEnglish` | Boolean |
| `lastLoginAt` | Timestamp | null |
| `latitude` | Int | Double |
| `licenseImageUrl` | String | null |
| `locationAddress` | String | Int | Double |
| `locationDistance` | Double | null |
| `locationLatitude` | Int | Double |
| `locationLongitude` | Int | Double |
| `longitude` | Int | Double |
| `membershipType` | String |
| `myChatRoomLastSeen` | Map |
| `myChatRoomLastSeen.{uid}` | Timestamp |
| `myChatRooms` | Array |
| `myChatRooms[]` | Element<> | Element<String> |
| `myCommentIds` | Array |
| `myCommentIds[]` | Element<> |
| `myFavoriteIds` | Array |
| `myFavoriteIds[]` | Element<> |
| `myInvitationLink` | String |
| `myVoteIds` | Array |
| `myVoteIds[]` | Element<> |
| `name` | String | null |
| `nickname` | String |
| `numberOfInvitations` | Int |
| `openChatLink` | null |
| `openDays` | Array |
| `openDays[]` | Element<Boolean> |
| `openRestDays` | Array |
| `openRestDays[]` | Element<Boolean> | Element<> |
| `openTime` | Array |
| `openTime[]` | Element<> | Element<String> |
| `phoneNum` | String |
| `point` | Int |
| `profileImageBlurHash` | null |
| `pushToken` | String |
| `pushTokenUpdatedAt` | Timestamp |
| `receiveFavoriteCount` | Int |
| `reivewCount` | Map |
| `restEndTime` | Array |
| `restEndTime[]` | Element<> |
| `restStartTime` | Array |
| `restStartTime[]` | Element<String> | Element<> |
| `reviewCount` | Map |
| `selectedDays` | null |
| `selectedGender` | String |
| `signUpMethod` | String |
| `signUpMethodType` | String |
| `signUpMethodTypeName` | String |
| `storeAddress` | String | null |
| `storeId` | String |
| `storeName` | String | null |
| `storePhoneNum` | String | null |
| `tags` | String | null |
| `uid` | String |
| `updateAt` | Timestamp | null |
| `userStatusType` | String | null |
| `userStatusTypeName` | String | null |
| `userType` | String |
| `userTypeName` | String | null |

> 마이그레이션 메모: `users.favoriteIds[]` → `tb_user_bookmark.bookmark_target_user_id`,
> 대상 사용자(`users`)의 `genderType/ageType/userType` → `user_gender_code/user_agg_code/user_type_code`.


## Collection: usersFavorites

- Path: `usersFavorites`

| Field | Type |
|---|---|
| `ageType` | String |
| `ageTypeName` | String |
| `allowNoticeEventNotification` | Boolean |
| `allowPushNotification` | Boolean |
| `birth` | String |
| `blockIds` | Array |
| `blockIds[]` | Element<> |
| `createAt` | Timestamp |
| `designerAllCloseTime` | Array |
| `designerAllCloseTime[]` | Element<String> | Element<> |
| `designerAuthStatus` | String |
| `designerAuthStatusType` | String |
| `designerAuthStatusTypeName` | String |
| `designerAutoConfirmAppointment` | Boolean |
| `designerCloseTime` | Array |
| `designerCloseTime[]` | Element<String> | Element<> |
| `designerDetailDynamicLinkUrl` | String |
| `designerInfo` | String |
| `designerIsWork` | Boolean |
| `designerLicenseImageUrl` | String |
| `designerOpenDays` | Array |
| `designerOpenDays[]` | Element<Boolean> |
| `designerOpenTime` | Array |
| `designerOpenTime[]` | Element<String> | Element<> |
| `designerPhotos` | Array |
| `designerPhotos[]` | Element<String> | Element<> |
| `designerTags` | String |
| `email` | String |
| `favoriteId` | String |
| `favoriteIds` | Array |
| `favoriteIds[]` | Element<String> | Element<> |
| `genderName` | String |
| `genderType` | String |
| `genderTypeName` | String |
| `imageUrl` | String |
| `isAgreePrivacy` | Boolean |
| `isAgreeTerms` | Boolean |
| `isNotificationAdvertisement` | Boolean |
| `isNotificationAdvertisementAt` | null |
| `isNotificationAll` | Boolean |
| `isNotificationAllAt` | Timestamp | null |
| `isNotificationAppointment` | Boolean |
| `isNotificationAppointmentAt` | Timestamp | null |
| `isNotificationChat` | Boolean |
| `isNotificationChatAt` | null |
| `isNotificationNoticeAt` | null |
| `isNotificationOffer` | Boolean |
| `isNotificationOfferAt` | null |
| `lastLoginAt` | Timestamp |
| `locationAddress` | String |
| `locationDistance` | Int | Double |
| `locationLatitude` | Double |
| `locationLongitude` | Double |
| `name` | String |
| `nickname` | String |
| `phoneNum` | String |
| `pushToken` | String |
| `reivewCount` | Map |
| `reviewCount` | Map |
| `signUpMethod` | String |
| `signUpMethodType` | String |
| `signUpMethodTypeName` | String |
| `storeAddress` | String |
| `storeId` | String |
| `storeName` | String |
| `storePhoneNum` | String |
| `uid` | String |
| `userStatusType` | String |
| `userStatusTypeName` | String |
| `userType` | String |
| `userTypeName` | String |


## Subcollection: appointments/menus

- Path: `appointments/{docId}/menus`

| Field | Type |
|---|---|
| `chestPrice` | String |
| `chinPrice` | String |
| `createAt` | Timestamp |
| `designerId` | String |
| `hairAddType` | String |
| `hairAddTypeName` | String |
| `hairGenderType` | String |
| `hairImageUrl` | Array |
| `hairImageUrl[]` | Element<> | Element<String> |
| `hairInfo` | String |
| `hairTime` | String |
| `hairTitle` | String |
| `id` | String |
| `isAddPrice` | Boolean |
| `isOpenMenu` | Boolean |
| `isSalePrice` | Boolean |
| `levelCode1` | String |
| `levelCode2` | String |
| `levelCode3` | String |
| `levelTitle1` | String |
| `levelTitle2` | String |
| `levelTitle3` | String |
| `order` | Int |
| `percent` | String |
| `price` | String |
| `salePrice` | String |
| `shoulderPrice` | String |
| `title` | String |
| `totalPrice` | String |
| `waistPrice` | String |


## Subcollection: chatRooms/chatMessages

- Path: `chatRooms/{docId}/chatMessages`

| Field | Type |
|---|---|
| `appointmentId` | null |
| `authorId` | String |
| `createAt` | Timestamp |
| `deleteMemberIds` | Array |
| `deleteMemberIds[]` | Element<> |
| `id` | String |
| `message` | String |
| `messageTextType` | String | null |
| `messageTextTypeName` | String | null |
| `messageType` | String |


## Subcollection: offers/designers

- Path: `offers/{docId}/designers`

| Field | Type |
|---|---|
| `ageType` | String |
| `ageTypeName` | String |
| `allowNoticeEventNotification` | Boolean |
| `allowPushNotification` | Boolean |
| `birth` | String |
| `blockIds` | Array |
| `blockIds[]` | Element<> |
| `createAt` | Timestamp |
| `designerAllCloseTime` | Array |
| `designerAllCloseTime[]` | Element<String> | Element<> |
| `designerAuthStatusType` | String |
| `designerAuthStatusTypeName` | String |
| `designerAutoConfirmAppointment` | Boolean |
| `designerCloseTime` | Array |
| `designerCloseTime[]` | Element<String> | Element<> |
| `designerDetailDynamicLinkUrl` | String |
| `designerInfo` | String |
| `designerIsWork` | Boolean |
| `designerLicenseImageUrl` | String |
| `designerOpenDays` | Array |
| `designerOpenDays[]` | Element<Boolean> |
| `designerOpenTime` | Array |
| `designerOpenTime[]` | Element<String> | Element<> |
| `designerPhotos` | Array |
| `designerPhotos[]` | Element<String> | Element<> |
| `designerTags` | String |
| `email` | String |
| `favoriteId` | String |
| `favoriteIds` | Array |
| `favoriteIds[]` | Element<String> | Element<> |
| `genderType` | String |
| `genderTypeName` | String |
| `imageUrl` | String |
| `isAgreePrivacy` | Boolean |
| `isAgreeTerms` | Boolean |
| `isNotificationAdvertisement` | Boolean |
| `isNotificationAdvertisementAt` | null |
| `isNotificationAll` | Boolean |
| `isNotificationAllAt` | Timestamp | null |
| `isNotificationAppointment` | Boolean |
| `isNotificationAppointmentAt` | Timestamp | null |
| `isNotificationChat` | Boolean |
| `isNotificationChatAt` | null |
| `isNotificationNoticeAt` | null |
| `isNotificationOffer` | Boolean |
| `isNotificationOfferAt` | null |
| `lastLoginAt` | Timestamp |
| `locationAddress` | String |
| `locationDistance` | Int | Double |
| `locationLatitude` | Double |
| `locationLongitude` | Double |
| `name` | String |
| `nickname` | String |
| `phoneNum` | String |
| `pushToken` | String |
| `reivewCount` | Map |
| `reivewCount.ReviewType.friendlyService` | Int |
| `reivewCount.ReviewType.goodCommunication` | Int |
| `reivewCount.ReviewType.greatStyling` | Int |
| `reivewCount.ReviewType.professionalSkill` | Int |
| `reviewCount` | Map |
| `signUpMethodType` | String |
| `signUpMethodTypeName` | String |
| `storeAddress` | String |
| `storeId` | String |
| `storeName` | String |
| `storePhoneNum` | String |
| `uid` | String |
| `userStatusType` | String |
| `userStatusTypeName` | String |
| `userType` | String |
| `userTypeName` | String |


## Subcollection: reservations/menus

- Path: `reservations/{docId}/menus`

⚠️ No documents found (or no fields detected in sampled docs).

## Subcollection: users/menus

- Path: `users/{docId}/menus`

| Field | Type |
|---|---|
| `chestPrice` | String |
| `chinPrice` | String |
| `createAt` | Timestamp |
| `designerId` | String |
| `hairAddTitle` | null |
| `hairAddType` | String |
| `hairAddTypeName` | null |
| `hairGenderType` | String |
| `hairImageUrl` | Array |
| `hairImageUrl[]` | Element<String> | Element<> |
| `hairInfo` | String |
| `hairTime` | String |
| `hairTitle` | null |
| `id` | String |
| `isAddPrice` | Boolean |
| `isOpenMenu` | Boolean |
| `isSalePrice` | Boolean |
| `levelCode1` | String |
| `levelCode2` | String |
| `levelCode3` | String |
| `levelTitle1` | String |
| `levelTitle2` | String |
| `levelTitle3` | String |
| `order` | Int |
| `percent` | String |
| `price` | String |
| `salePrice` | String |
| `selectedHairAddType` | null |
| `shoulderPrice` | String |
| `title` | String |
| `totalPrice` | String |
| `waistPrice` | String |


## Subcollection: users/notificationCenters

- Path: `users/{docId}/notificationCenters`

| Field | Type |
|---|---|
| `appointmentId` | String | null |
| `appointmentModel` | Map | null |
| `appointmentModel.addHairPrice` | null |
| `appointmentModel.appointmentStatusType` | String |
| `appointmentModel.appointmentStatusTypeName` | String |
| `appointmentModel.cancelReason` | String | null |
| `appointmentModel.createAt` | Timestamp |
| `appointmentModel.designerImageUrl` | String |
| `appointmentModel.designerModel` | Map |
| `appointmentModel.designerModel.ageType` | String |
| `appointmentModel.designerModel.ageTypeName` | String |
| `appointmentModel.designerModel.allowNoticeEventNotification` | Boolean |
| `appointmentModel.designerModel.allowPushNotification` | Boolean |
| `appointmentModel.designerModel.birth` | String |
| `appointmentModel.designerModel.blockIds` | Array |
| `appointmentModel.designerModel.blockIds[]` | Element<> |
| `appointmentModel.designerModel.createAt` | Timestamp |
| `appointmentModel.designerModel.designerAllCloseTime` | Array |
| `appointmentModel.designerModel.designerAllCloseTime[]` | Element<> |
| `appointmentModel.designerModel.designerAuthStatus` | String |
| `appointmentModel.designerModel.designerAuthStatusType` | String |
| `appointmentModel.designerModel.designerAuthStatusTypeName` | String |
| `appointmentModel.designerModel.designerAutoConfirmAppointment` | Boolean |
| `appointmentModel.designerModel.designerCloseTime` | Array |
| `appointmentModel.designerModel.designerCloseTime[]` | Element<String> |
| `appointmentModel.designerModel.designerDetailDynamicLinkUrl` | String |
| `appointmentModel.designerModel.designerInfo` | String |
| `appointmentModel.designerModel.designerIsWork` | Boolean |
| `appointmentModel.designerModel.designerLicenseImageUrl` | String |
| `appointmentModel.designerModel.designerOpenDays` | Array |
| `appointmentModel.designerModel.designerOpenDays[]` | Element<Boolean> |
| `appointmentModel.designerModel.designerOpenTime` | Array |
| `appointmentModel.designerModel.designerOpenTime[]` | Element<String> |
| `appointmentModel.designerModel.designerPhotos` | Array |
| `appointmentModel.designerModel.designerPhotos[]` | Element<> |
| `appointmentModel.designerModel.designerTags` | String |
| `appointmentModel.designerModel.email` | String |
| `appointmentModel.designerModel.favoriteId` | String |
| `appointmentModel.designerModel.favoriteIds` | Array |
| `appointmentModel.designerModel.favoriteIds[]` | Element<> |
| `appointmentModel.designerModel.genderType` | String |
| `appointmentModel.designerModel.genderTypeName` | String |
| `appointmentModel.designerModel.imageUrl` | String |
| `appointmentModel.designerModel.isAgreePrivacy` | Boolean |
| `appointmentModel.designerModel.isAgreeTerms` | Boolean |
| `appointmentModel.designerModel.lastLoginAt` | Timestamp | null |
| `appointmentModel.designerModel.locationAddress` | String |
| `appointmentModel.designerModel.locationDistance` | Int | Double |
| `appointmentModel.designerModel.locationLatitude` | Double |
| `appointmentModel.designerModel.locationLongitude` | Double |
| `appointmentModel.designerModel.name` | String |
| `appointmentModel.designerModel.nickname` | String |
| `appointmentModel.designerModel.phoneNum` | String |
| `appointmentModel.designerModel.pushToken` | String |
| `appointmentModel.designerModel.signUpMethod` | String |
| `appointmentModel.designerModel.signUpMethodType` | String |
| `appointmentModel.designerModel.signUpMethodTypeName` | String |
| `appointmentModel.designerModel.storeAddress` | String |
| `appointmentModel.designerModel.storeId` | String |
| `appointmentModel.designerModel.storeName` | String |
| `appointmentModel.designerModel.storePhoneNum` | String |
| `appointmentModel.designerModel.uid` | String |
| `appointmentModel.designerModel.userStatusType` | String |
| `appointmentModel.designerModel.userStatusTypeName` | String |
| `appointmentModel.designerModel.userType` | String |
| `appointmentModel.designerModel.userTypeName` | String |
| `appointmentModel.designerName` | String |
| `appointmentModel.designerUid` | String |
| `appointmentModel.endAt` | Timestamp |
| `appointmentModel.hairTitle` | String |
| `appointmentModel.id` | String |
| `appointmentModel.isModifyOfAppointment` | Boolean |
| `appointmentModel.menus` | Array |
| `appointmentModel.menus[]` | Element<> |
| `appointmentModel.paymentMethodType` | String |
| `appointmentModel.paymentMethodTypeName` | String |
| `appointmentModel.price` | String |
| `appointmentModel.startAt` | Timestamp |
| `appointmentModel.storeId` | String |
| `appointmentModel.storeName` | String |
| `appointmentModel.timer` | String |
| `appointmentModel.userName` | String |
| `appointmentModel.userPhoneNum` | String |
| `appointmentModel.userUid` | String |
| `createAt` | Timestamp |
| `desingerName` | String |
| `eventWhenClick` | String |
| `hairTitle` | String |
| `id` | String |
| `message` | String |
| `notificationCheck` | Boolean |
| `NotificationCheck` | Boolean |
| `notificationType` | String |
| `notificationTypeName` | String |
| `receiverUid` | String |
| `reservationModel` | Map | null |
| `reservationModel.addHairOption` | String |
| `reservationModel.addHairPrice` | null |
| `reservationModel.createAt` | null |
| `reservationModel.designerImageUrl` | String | null |
| `reservationModel.designerModel` | Map |
| `reservationModel.designerModel. chargeHistory` | Array |
| `reservationModel.designerModel. chargeHistory[]` | Element<> |
| `reservationModel.designerModel.accountInfo` | String |
| `reservationModel.designerModel.address` | String |
| `reservationModel.designerModel.allowActivityNotification` | Boolean |
| `reservationModel.designerModel.allowNoticeEventNotification` | Boolean |
| `reservationModel.designerModel.allowPushNotification` | Boolean |
| `reservationModel.designerModel.birth` | String |
| `reservationModel.designerModel.blockIds` | Array |
| `reservationModel.designerModel.blockIds[]` | Element<> |
| `reservationModel.designerModel.closeTime` | Array |
| `reservationModel.designerModel.closeTime[]` | Element<String> |
| `reservationModel.designerModel.createAt` | Timestamp |
| `reservationModel.designerModel.designerAuthStatus` | String |
| `reservationModel.designerModel.designerCloseTime` | Array |
| `reservationModel.designerModel.designerCloseTime[]` | Element<String> |
| `reservationModel.designerModel.designerInfo` | String |
| `reservationModel.designerModel.designerIsWork` | Boolean |
| `reservationModel.designerModel.designerLicenseImageUrl` | String |
| `reservationModel.designerModel.designerOpenDays` | Array |
| `reservationModel.designerModel.designerOpenDays[]` | Element<Boolean> |
| `reservationModel.designerModel.designerOpenTime` | Array |
| `reservationModel.designerModel.designerOpenTime[]` | Element<String> |
| `reservationModel.designerModel.designerPhotos` | Array |
| `reservationModel.designerModel.designerPhotos[]` | Element<> | Element<String> |
| `reservationModel.designerModel.designerRestTimes` | null |
| `reservationModel.designerModel.designerTags` | String |
| `reservationModel.designerModel.distance` | Int | Double |
| `reservationModel.designerModel.email` | String |
| `reservationModel.designerModel.favoriteId` | String |
| `reservationModel.designerModel.favoriteIds` | Array |
| `reservationModel.designerModel.favoriteIds[]` | Element<> |
| `reservationModel.designerModel.genderName` | String |
| `reservationModel.designerModel.genderType` | String |
| `reservationModel.designerModel.hairImages` | Array |
| `reservationModel.designerModel.hairImages[]` | Element<> |
| `reservationModel.designerModel.hairTitle` | String |
| `reservationModel.designerModel.imageUrl` | String |
| `reservationModel.designerModel.isLastReadMessage` | Boolean |
| `reservationModel.designerModel.isWork` | Boolean |
| `reservationModel.designerModel.languageEnglish` | Boolean |
| `reservationModel.designerModel.latitude` | Double |
| `reservationModel.designerModel.licenseImageUrl` | String |
| `reservationModel.designerModel.locationAddress` | String |
| `reservationModel.designerModel.locationDistance` | Double |
| `reservationModel.designerModel.locationLatitude` | Double |
| `reservationModel.designerModel.locationLongitude` | Double |
| `reservationModel.designerModel.longitude` | Double |
| `reservationModel.designerModel.membershipType` | String |
| `reservationModel.designerModel.myChatRoomLastSeen` | Map |
| `reservationModel.designerModel.myChatRooms` | Array |
| `reservationModel.designerModel.myChatRooms[]` | Element<String> |
| `reservationModel.designerModel.myCommentIds` | Array |
| `reservationModel.designerModel.myCommentIds[]` | Element<> |
| `reservationModel.designerModel.myFavoriteIds` | Array |
| `reservationModel.designerModel.myFavoriteIds[]` | Element<> |
| `reservationModel.designerModel.myInvitationLink` | String |
| `reservationModel.designerModel.myVoteIds` | Array |
| `reservationModel.designerModel.myVoteIds[]` | Element<> |
| `reservationModel.designerModel.name` | String |
| `reservationModel.designerModel.nickname` | String |
| `reservationModel.designerModel.numberOfInvitations` | Int |
| `reservationModel.designerModel.openChatLink` | String |
| `reservationModel.designerModel.openDays` | Array |
| `reservationModel.designerModel.openDays[]` | Element<Boolean> |
| `reservationModel.designerModel.openTime` | Array |
| `reservationModel.designerModel.openTime[]` | Element<String> |
| `reservationModel.designerModel.phoneNum` | String |
| `reservationModel.designerModel.point` | Int |
| `reservationModel.designerModel.profileImageBlurHash` | null |
| `reservationModel.designerModel.pushToken` | String |
| `reservationModel.designerModel.receiveFavoriteCount` | Int |
| `reservationModel.designerModel.selectedDays` | null |
| `reservationModel.designerModel.selectedGender` | String |
| `reservationModel.designerModel.signUpMethod` | String |
| `reservationModel.designerModel.storeAddress` | String |
| `reservationModel.designerModel.storeId` | String |
| `reservationModel.designerModel.storeName` | String |
| `reservationModel.designerModel.storePhoneNum` | String |
| `reservationModel.designerModel.tags` | String |
| `reservationModel.designerModel.uid` | String |
| `reservationModel.designerModel.userType` | String |
| `reservationModel.designerName` | String |
| `reservationModel.designerUid` | String |
| `reservationModel.endAt` | Timestamp |
| `reservationModel.hairCutType` | String |
| `reservationModel.hairTitle` | String |
| `reservationModel.id` | String |
| `reservationModel.imageUrl` | String | null |
| `reservationModel.isClosedToday` | Boolean |
| `reservationModel.isFinished` | Boolean |
| `reservationModel.isRead` | Boolean |
| `reservationModel.menuModel` | Map |
| `reservationModel.menuModel.chestPrice` | String |
| `reservationModel.menuModel.chinPrice` | String |
| `reservationModel.menuModel.createAt` | Timestamp |
| `reservationModel.menuModel.designerId` | String |
| `reservationModel.menuModel.hairAddTitle` | String |
| `reservationModel.menuModel.hairAddType` | String |
| `reservationModel.menuModel.hairGenderType` | String |
| `reservationModel.menuModel.hairImageUrl` | Array |
| `reservationModel.menuModel.hairImageUrl[]` | Element<String> | Element<> |
| `reservationModel.menuModel.hairInfo` | String |
| `reservationModel.menuModel.hairTime` | String |
| `reservationModel.menuModel.id` | String |
| `reservationModel.menuModel.isAddPrice` | Boolean |
| `reservationModel.menuModel.isOpenMenu` | Boolean |
| `reservationModel.menuModel.isSalePrice` | Boolean |
| `reservationModel.menuModel.order` | Int |
| `reservationModel.menuModel.percent` | String |
| `reservationModel.menuModel.price` | String |
| `reservationModel.menuModel.salePrice` | String |
| `reservationModel.menuModel.selectedHairAddType` | null |
| `reservationModel.menuModel.shoulderPrice` | String |
| `reservationModel.menuModel.title` | String |
| `reservationModel.menuModel.totalPrice` | String |
| `reservationModel.menuModel.waistPrice` | String |
| `reservationModel.modifyOfReservation` | Boolean |
| `reservationModel.paymentMethod` | String |
| `reservationModel.price` | String |
| `reservationModel.reservationStatus` | Boolean |
| `reservationModel.reservationType` | String |
| `reservationModel.selectHairAddType` | String |
| `reservationModel.startAt` | Timestamp |
| `reservationModel.storeName` | String |
| `reservationModel.timer` | String |
| `reservationModel.userName` | String |
| `reservationModel.userPhoneNum` | String |
| `reservationModel.userUid` | String |
| `reserveDate` | String |
| `title` | String |
| `topic` | String |
| `userName` | String |


