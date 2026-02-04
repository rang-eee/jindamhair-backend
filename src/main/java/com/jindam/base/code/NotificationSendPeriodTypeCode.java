
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum NotificationSendPeriodTypeCode implements CodeEnum {
    // 알림 송신 기간 유형 코드 : NSPT

    NSPT001("즉시", "SendPeriodType.immediately"), //
    NSPT002("예약", "SendPeriodType.appointment"), //
    ;

    private final String text;
    private final String front;
}