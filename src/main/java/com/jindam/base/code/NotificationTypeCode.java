
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum NotificationTypeCode implements CodeEnum {
    // 알림 유형 코드 : NTTP

    NTTP001("고객 취소"), //
    NTTP002("고객 예약"), //
    NTTP003("고객 수정"), //
    NTTP004("디자이너 취소"), //
    NTTP005("디자이너 예약"), //
    NTTP006("디자이너 수정"), //
    NTTP007("고객 예약요청"), //
    NTTP008("시술 완료"), //
    NTTP009("면허증 확인 완료"), //
    NTTP010("면허증 거절"), //
    NTTP011("면허증 확인 중"), //
    NTTP012("관리자 웹 발송"), //
    NTTP013("디자이너 제안 수락"), //
    NTTP014("고객 제안 확정"), //
    NTTP015("디자이너 가입 확인"), //
    ;

    private final String text;
}