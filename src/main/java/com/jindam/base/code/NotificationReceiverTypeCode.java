
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum NotificationReceiverTypeCode implements CodeEnum {
    // 알림 수신자 유형 코드 : NTRT

    all("전체", "TargetUserType.all"), //
    designer("디자이너", "TargetUserType.designer"), //
    customer("고객", "TargetUserType.customer"), //
    ;

    private final String text;
    private final String front;
}
