
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum NotificationTypeCode implements CodeEnum {
    // 알림 유형 코드 : NTTP

    NTTP001("고객 취소", "NotificationType.userCancel"), //
    NTTP002("고객 예약", "NotificationType.userAppointment"), //
    NTTP003("고객 수정", "NotificationType.userModifyAppointment"), //
    NTTP004("디자이너 취소", "NotificationType.designerCancel"), //
    NTTP005("디자이너 예약", "NotificationType.designerAppointment"), //
    NTTP006("디자이너 수정", "NotificationType.designerModifyAppointment"), //
    NTTP007("고객 예약요청", "NotificationType.cofirmAppointment"), //
    NTTP008("시술 완료", "NotificationType.finishAppointment"), //
    NTTP009("면허증 확인 완료", "NotificationType.authComplete"), //
    NTTP010("면허증 거절", "NotificationType.authReject"), //
    NTTP011("면허증 확인 중", "NotificationType.authWait"), //
    NTTP012("관리자 웹 발송", "NotificationType.webNotification"), //
    NTTP013("디자이너 제안 수락", "NotificationType.acceptOffer"), //
    NTTP014("고객 제안 확정", "NotificationType.cofirmOffer"), //
    NTTP015("디자이너 가입 확인", "NotificationType.confirmSignupDesigner"), //
    ;

    private final String text;
    private final String front;
}