
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum UserAggCode implements CodeEnum {
    // 사용자 연령대 코드 : USAG

    USAG001("미확인"), //
    USAG002("10대 이하"), //
    USAG003("10대"), //
    USAG004("20대"), //
    USAG005("30대"), //
    USAG006("40대"), //
    USAG007("50대"), //
    USAG008("60대 이상"), //
    ;

    private final String text;
}
