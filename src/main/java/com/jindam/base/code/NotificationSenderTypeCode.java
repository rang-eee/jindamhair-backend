
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum NotificationSenderTypeCode implements CodeEnum {
    // 알림 송신자 유형 코드 : NTST

    NTST001("관리자", "SendUserType.manage"), //
    NTST002("디자이너", "SendUserType.designer"), //
    ;

    private final String text;
    private final String front;
}
