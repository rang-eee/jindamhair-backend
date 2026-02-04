
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum NotificationReceiverTypeCode implements CodeEnum {
    // 알림 수신자 유형 코드 : NTRT

    NTRT001("전체", "TargetUserType.all"), //
    NTRT002("디자이너", "TargetUserType.designer"), //
    NTRT003("고객", "TargetUserType.customer"), //
    ;

    private final String text;
    private final String front;
}
