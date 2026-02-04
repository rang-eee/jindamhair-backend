
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserTypeCode implements CodeEnum {
    // 사용자 유형 코드 : USTP

    USTP001("고객", "UserType.customer"), //
    USTP002("디자이너", "UserType.designer"), //
    ;

    private final String text;
    private final String front;
}
