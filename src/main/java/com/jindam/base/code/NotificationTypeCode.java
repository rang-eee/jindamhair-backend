
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum NotificationTypeCode implements CodeEnum {
    // 알림 유형 코드 : NTTP

    userCancel("고객 취소", "NotificationType.userCancel"), //
    userAppointment("고객 예약", "NotificationType.userAppointment"), //
    userModifyAppointment("고객 수정", "NotificationType.userModifyAppointment"), //
    designerCancel("디자이너 취소", "NotificationType.designerCancel"), //
    designerAppointment("디자이너 예약", "NotificationType.designerAppointment"), //
    designerModifyAppointment("디자이너 수정", "NotificationType.designerModifyAppointment"), //
    cofirmAppointment("고객 예약요청", "NotificationType.cofirmAppointment"), //
    finishAppointment("시술 완료", "NotificationType.finishAppointment"), //
    authComplete("면허증 확인 완료", "NotificationType.authComplete"), //
    authReject("면허증 거절", "NotificationType.authReject"), //
    authWait("면허증 확인 중", "NotificationType.authWait"), //
    webNotification("관리자 웹 발송", "NotificationType.webNotification"), //
    acceptOffer("디자이너 제안 수락", "NotificationType.acceptOffer"), //
    cofirmOffer("고객 제안 확정", "NotificationType.cofirmOffer"), //
    confirmSignupDesigner("디자이너 가입 확인", "NotificationType.confirmSignupDesigner"), //
    ;

    private final String text;
    private final String front;
}