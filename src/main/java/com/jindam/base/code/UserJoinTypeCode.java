
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum UserJoinTypeCode implements CodeEnum {
    // 사용자 가입 유형 코드 : UJTP

    UJTP001("이메일"), //
    UJTP002("애플"), //
    UJTP003("구글"), //
    UJTP004("페이스북"), //
    UJTP005("카카오"), //
    UJTP006("네이버"), //
    ;

    private final String text;
}
