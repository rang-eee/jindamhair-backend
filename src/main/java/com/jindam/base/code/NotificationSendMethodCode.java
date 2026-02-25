
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum NotificationSendMethodCode implements CodeEnum {
    // 알림 송신 방법 코드 : NTSM

    all("전체", "SendMethodType.all"), //
    push("푸시", "SendMethodType.push"), //
    sms("메시지", "SendMethodType.sms"), //
    ;

    private final String text;
    private final String front;
}