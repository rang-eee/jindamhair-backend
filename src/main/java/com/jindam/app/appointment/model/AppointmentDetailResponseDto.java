package com.jindam.app.appointment.model;

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
@Schema(description = " 응답 모델")
public class AppointmentDetailResponseDto {
    @Schema(description = "예약 ID", example = "123")
    private String appointmentId;

    @Schema(description = "고객 사용자ID", example = "123")
    private String customerUid;

    @Schema(description = "디자이너 사용자ID", example = "123")
    private String designerUid;

    @Schema(description = "헤어샵 ID", example = "123")
    private String designerShopId;

    @Schema(description = "예약 상태 코드", example = "123")
    private AppointmentStatusCode appointmentStatusCode;

    @Schema(description = "예약 시작 유형 코드", example = "123")
    private AppointmentStartTypeCode appointmentStartTypeCode;

    @Schema(description = "총 금액", example = "123")
    private String totalAmount;

    @Schema(description = "예약 금액", example = "123")
    private String appointmentAmount;

    @Schema(description = "시술 시작 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime treatmentStartAt;

    @Schema(description = "시술 종료 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime treatmentEndAt;

    @Schema(description = "결제 방법 코드", example = "123")
    private PaymentMethodCode paymentMethodCode;

    @Schema(description = "예약 내용", example = "123")
    private String appointmentContent;

    @Schema(description = "취소 사유 내용", example = "123")
    private String cancelReasonContent;

    @Schema(description = "후기 ID", example = "123")
    private String reviewId;

    @Schema(description = "고객 명", example = "123")
    private String customerName;

    @Schema(description = "고객 닉네임", example = "123")
    private String customerNickname;

    @Schema(description = "고객 연락처", example = "123")
    private String customerContact;

    @Schema(description = "디자이너 명", example = "123")
    private String designerName;

    @Schema(description = "디자이너 닉네임", example = "123")
    private String designerNickname;

    @Schema(description = "디자이너 연락처", example = "123")
    private String designerContact;

    @Schema(description = "헤어샵 명", example = "123")
    private String shopName;

    @Schema(description = "헤어샵 주소", example = "123")
    private String shopAddr;

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
    /*고객---------------------------------------------------------------------------*/

    @Schema(description = "사용자 이메일", example = "")
    private String customerUserEmail;

    @Schema(description = "사용자 연락처", example = "")
    private String customerUserContact;

    @Schema(description = "사용자 명", example = "")
    private String customerUserName;

    @Schema(description = "사용자 닉네임", example = "")
    private String customerUserNickname;

    @Schema(description = "사용자 상태 코드", example = "")
    private UserStatusCode customerUserStatusCode;

    @Schema(description = "사용자 성별 코드", example = "")
    private UserGenderCode customerUserGenderCode;

    @Schema(description = "사용자 연령대 코드", example = "")
    private UserAggCode customerUserAggCode;

    @Schema(description = "사용자 유형 코드", example = "")
    private UserTypeCode customerUserTypeCode;

    @Schema(description = "사용자 생년월일", example = "")
    private String customerUserBrdt;

    @Schema(description = "사용자 가입 유형 코드", example = "")
    private UserJoinTypeCode customerUserJoinTypeCode;

    @Schema(description = "푸시 토큰", example = "")
    private String customerPushToken;

    @Schema(description = "최종 로그인 일시", example = "")
    private LocalDateTime customerLastLoginAt;

    @Schema(description = "즐겨찾기 사용자 ID 배열", example = "")
    private List<String> customerBookmarkUserIdArr;

    @Schema(description = "차단 사용자 ID 배열", example = "")
    private List<String> customerInterceptionUserIdArr;

    @Schema(description = "개인정보처리방침 동의 여부", example = "")
    private String customerPrvcplcAgreeYn;

    @Schema(description = "서비스 이용약관 동의 여부", example = "")
    private String customerTermsAgreeYn;

    @Schema(description = "전체 알림 수신 여부", example = "")
    private String customerAllNotificationReceptionYn;

    @Schema(description = "전체 알림 수신 일시", example = "")
    private LocalDateTime customerAllNotificationReceptionAt;

    @Schema(description = "공지 알림 수신 여부", example = "")
    private String customerNoticeNotificationReceptionYn;

    @Schema(description = "공지 알림 수신 일시", example = "")
    private LocalDateTime customerNoticeNotificationReceptionAt;

    @Schema(description = "마케팅 알림 수신 여부", example = "")
    private String customerMarketingNotificationReceptionYn;

    @Schema(description = "마케팅 알림 수신 일시", example = "")
    private LocalDateTime customerMarketingNotificationReceptionAt;

    @Schema(description = "제안 알림 수신 여부", example = "")
    private String customerOfferNotificationReceptionYn;

    @Schema(description = "제안 알림 수신 일시", example = "")
    private LocalDateTime customerOfferNotificationReceptionAt;

    @Schema(description = "채팅 알림 수신 여부", example = "")
    private String customerChatNotificationReceptionYn;

    @Schema(description = "채팅 알림 수신 일시", example = "")
    private LocalDateTime customerChatNotificationReceptionAt;

    @Schema(description = "위치 주소", example = "")
    private String customerPositionAddr;

    @Schema(description = "위치 위도", example = "")
    private String customerPositionLatt;

    @Schema(description = "위치 경도", example = "")
    private String customerPositionLngt;

    @Schema(description = "위치 거리", example = "")
    private String customerPositionDistance;

    @Schema(description = "프로필 사진 파일 ID", example = "")
    private String customerProfilePhotoFileId;

    @Schema(description = "디자이너 승인 상태 코드", example = "")
    private DesignerApprStatusCode customerDesignerApprStatusCode;

    @Schema(description = "디자이너 소개 내용", example = "")
    private String customerDesignerIntroduceContent;

    @Schema(description = "디자이너 태그 배열", example = "")
    private List<String> customerDesignerTagArr;

    @Schema(description = "디자이너 근무 상태 코드", example = "")
    private DesignerWorkStatusCode customerDesignerWorkStatusCode;

    @Schema(description = "디자이너 오픈 요일 배열", example = "")
    private List<String> customerDesignerOpenDayArr;

    @Schema(description = "디자이너 오픈 시간 배열", example = "")
    private List<String> customerDesignerOpenTimeArr;

    @Schema(description = "디자이너 오프 시간 배열", example = "")
    private List<String> customerDesignerCloseTimeArr;

    @Schema(description = "디자이너 예약 자동 확정 여부", example = "")
    private String customerDesignerAppointmentAutomaticConfirmYn;

    @Schema(description = "디자이너 앱링크 URL", example = "")
    private String customerDesignerApplinkUrl;

    @Schema(description = "디자이너 세부 사진 파일 ID", example = "")
    private String customerDesignerDetailPhotoFileId;

    @Schema(description = "디자이너 계좌 브랜드 코드", example = "")
    private DesignerAccountBrandCode customerDesignerAccountBrandCode;

    /*디자이너-------------------------------------------------------------*/

    @Schema(description = "사용자 이메일", example = "")
    private String designerUserEmail;

    @Schema(description = "사용자 연락처", example = "")
    private String designerUserContact;

    @Schema(description = "사용자 명", example = "")
    private String designerUserName;

    @Schema(description = "사용자 닉네임", example = "")
    private String designerUserNickname;

    @Schema(description = "사용자 상태 코드", example = "")
    private UserStatusCode designerUserStatusCode;

    @Schema(description = "사용자 성별 코드", example = "")
    private UserGenderCode designerUserGenderCode;

    @Schema(description = "사용자 연령대 코드", example = "")
    private UserAggCode designerUserAggCode;

    @Schema(description = "사용자 유형 코드", example = "")
    private UserTypeCode designerUserTypeCode;

    @Schema(description = "사용자 생년월일", example = "")
    private String designerUserBrdt;

    @Schema(description = "사용자 가입 유형 코드", example = "")
    private UserJoinTypeCode designerUserJoinTypeCode;

    @Schema(description = "푸시 토큰", example = "")
    private String designerPushToken;

    @Schema(description = "최종 로그인 일시", example = "")
    private LocalDateTime designerLastLoginAt;

    @Schema(description = "즐겨찾기 사용자 ID 배열", example = "")
    private List<String> designerBookmarkUserIdArr;

    @Schema(description = "차단 사용자 ID 배열", example = "")
    private List<String> designerInterceptionUserIdArr;

    @Schema(description = "개인정보처리방침 동의 여부", example = "")
    private String designerPrvcplcAgreeYn;

    @Schema(description = "서비스 이용약관 동의 여부", example = "")
    private String designerTermsAgreeYn;

    @Schema(description = "전체 알림 수신 여부", example = "")
    private String designerAllNotificationReceptionYn;

    @Schema(description = "전체 알림 수신 일시", example = "")
    private LocalDateTime designerAllNotificationReceptionAt;

    @Schema(description = "공지 알림 수신 여부", example = "")
    private String designerNoticeNotificationReceptionYn;

    @Schema(description = "공지 알림 수신 일시", example = "")
    private LocalDateTime designerNoticeNotificationReceptionAt;

    @Schema(description = "마케팅 알림 수신 여부", example = "")
    private String designerMarketingNotificationReceptionYn;

    @Schema(description = "마케팅 알림 수신 일시", example = "")
    private LocalDateTime designerMarketingNotificationReceptionAt;

    @Schema(description = "제안 알림 수신 여부", example = "")
    private String designerOfferNotificationReceptionYn;

    @Schema(description = "제안 알림 수신 일시", example = "")
    private LocalDateTime designerOfferNotificationReceptionAt;

    @Schema(description = "채팅 알림 수신 여부", example = "")
    private String designerChatNotificationReceptionYn;

    @Schema(description = "채팅 알림 수신 일시", example = "")
    private LocalDateTime designerChatNotificationReceptionAt;

    @Schema(description = "위치 주소", example = "")
    private String designerPositionAddr;

    @Schema(description = "위치 위도", example = "")
    private String designerPositionLatt;

    @Schema(description = "위치 경도", example = "")
    private String designerPositionLngt;

    @Schema(description = "위치 거리", example = "")
    private String designerPositionDistance;

    @Schema(description = "프로필 사진 파일 ID", example = "")
    private String designerProfilePhotoFileId;

    @Schema(description = "디자이너 승인 상태 코드", example = "")
    private DesignerApprStatusCode designerDesignerApprStatusCode;

    @Schema(description = "디자이너 소개 내용", example = "")
    private String designerDesignerIntroduceContent;

    @Schema(description = "디자이너 태그 배열", example = "")
    private List<String> designerDesignerTagArr;

    @Schema(description = "디자이너 근무 상태 코드", example = "")
    private DesignerWorkStatusCode designerDesignerWorkStatusCode;

    @Schema(description = "디자이너 오픈 요일 배열", example = "")
    private List<String> designerDesignerOpenDayArr;

    @Schema(description = "디자이너 오픈 시간 배열", example = "")
    private List<String> designerDesignerOpenTimeArr;

    @Schema(description = "디자이너 오프 시간 배열", example = "")
    private List<String> designerDesignerCloseTimeArr;

    @Schema(description = "디자이너 예약 자동 확정 여부", example = "")
    private String designerDesignerAppointmentAutomaticConfirmYn;

    @Schema(description = "디자이너 앱링크 URL", example = "")
    private String designerDesignerApplinkUrl;

    @Schema(description = "디자이너 세부 사진 파일 ID", example = "")
    private String designerDesignerDetailPhotoFileId;

    @Schema(description = "디자이너 계좌 브랜드 코드", example = "")
    private DesignerAccountBrandCode designerDesignerAccountBrandCode;

    @Schema(description = "예약 시술 목록", example = "")
    List<AppointmentTreatmentInsertRequestDto> treatmentList;
}
