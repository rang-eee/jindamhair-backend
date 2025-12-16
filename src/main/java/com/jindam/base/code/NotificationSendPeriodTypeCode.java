
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum NotificationSendPeriodTypeCode implements CodeEnum {
    // 알림 송신 기간 유형 코드 : NSPT

    NSPT001("즉시"), //
    NSPT002("예약"), //
    ;

    private final String text;
}