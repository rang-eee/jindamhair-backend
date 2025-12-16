
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum NotificationSendMethodCode implements CodeEnum {
    // 알림 송신 방법 코드 : NTSM

    NTSM001("전체"), //
    NTSM002("푸시"), //
    NTSM003("SMS"), //
    ;

    private final String text;
}