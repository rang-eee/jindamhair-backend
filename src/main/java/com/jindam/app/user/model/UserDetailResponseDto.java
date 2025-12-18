package com.jindam.app.user.model;

import com.jindam.base.code.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "사용자 상세 조회 응답 모델")
public class UserDetailResponseDto {

    @Schema(description = "사용자ID")
    private String uid;

    @Schema(description = "사용자 이메일")
    private String userEmail;

    @Schema(description = "사용자 연락처")
    private String userContact;

    @Schema(description = "사용자 명")
    private String userName;

    @Schema(description = "사용자 닉네임")
    private String userNickname;

    @Schema(description = "사용자 상태 코드")
    private UserStatusCode userStatusCode;

    @Schema(description = "사용자 성별 코드")
    private UserGenderCode userGenderCode;

    @Schema(description = "사용자 연령대 코드")
    private UserAggCode userAggCode;

    @Schema(description = "사용자 유형 코드")
    private UserTypeCode userTypeCode;

    @Schema(description = "사용자 생년월일")
    private String userBrdt;

    @Schema(description = "사용자 가입 유형 코드")
    private UserJoinTypeCode userJoinTypeCode;

    @Schema(description = "푸시 토큰푸시 토큰")
    private String pushToken;

    @Schema(description = "최종 로그인 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime lastLoginAt;

    @Schema(description = "즐겨찾기 사용자 ID 배열")
    private List<String> bookmarkUserIdArr;

    @Schema(description = "차단 사용자 ID 배열")
    private List<String> interceptionUserIdArr;

    @Schema(description = "개인정보처리방침 동의 여부", example = "Y")
    private String prvcplcAgreeYn;

    @Schema(description = "서비스 이용약관 동의 여부", example = "Y")
    private String termsAgreeYn;

    @Schema(description = "전체 알림 수신 여부", example = "Y")
    private String allNotificationReceptionYn;

    @Schema(description = "전체 알림 수신 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime allNotificationReceptionAt;

    @Schema(description = "공지 알림 수신 여부", example = "Y")
    private String noticeNotificationReceptionYn;

    @Schema(description = "공지 알림 수신 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime noticeNotificationReceptionAt;

    @Schema(description = "마케팅 알림 수신 여부", example = "Y")
    private String marketingNotificationReceptionYn;

    @Schema(description = "마케팅 알림 수신 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime marketingNotificationReceptionAt;

    @Schema(description = "제안 알림 수신 여부", example = "Y")
    private String offerNotificationReceptionYn;

    @Schema(description = "제안 알림 수신 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime offerNotificationReceptionAt;

    @Schema(description = "채팅 알림 수신 여부", example = "Y")
    private String chatNotificationReceptionYn;

    @Schema(description = "채팅 알림 수신 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime chatNotificationReceptionAt;

    @Schema(description = "위치 주소")
    private String positionAddr;

    @Schema(description = "위치 위도")
    private String positionLatt;

    @Schema(description = "위치 경도")
    private String positionLngt;

    @Schema(description = "위치 거리")
    private String positionDistance;

    @Schema(description = "프로필 사진 파일 ID")
    private String profilePhotoFileId;

    @Schema(description = "디자이너 승인 상태 코드")
    private DesignerApprStatusCode designerApprStatusCode;

    @Schema(description = "디자이너 소개 내용")
    private String designerIntroduceContent;

    @Schema(description = "디자이너 태그 배열")
    private List<String> designerTagArr;

    @Schema(description = "디자이너 근무 상태 코드")
    private DesignerWorkStatusCode designerWorkStatusCode;

    @Schema(description = "디자이너 오픈 요일 배열")
    private List<String> designerOpenDayArr;

    @Schema(description = "디자이너 오픈 시간 배열")
    private List<String> designerOpenTimeArr;

    @Schema(description = "디자이너 오프 시간 배열")
    private List<String> designerCloseTimeArr;

    @Schema(description = "디자이너 예약 자동 확정 여부", example = "Y")
    private String designerAppointmentAutomaticConfirmYn;

    @Schema(description = "디자이너 앱링크 URL")
    private String designerApplinkUrl;

    @Schema(description = "디자이너 세부 사진 파일 ID")
    private String designerDetailPhotoFileId;

    @Schema(description = "디자이너 계좌 브랜드 코드")
    private DesignerApprStatusCode designerAccountBrandCode;

    @Schema(description = "생성 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime createAt;

    @Schema(description = "생성 ID", example = "123")
    private String createId;

    @Schema(description = "수정 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime updateAt;

    @Schema(description = "수정 ID", example = "123")
    private String updateId;

    @Schema(description = "삭제 여부", example = "N")
    private String deleteYn;

    @Schema(description = "삭제 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime deleteAt;

    @Schema(description = "삭제 ID", example = "123")
    private String deleteId;

}
