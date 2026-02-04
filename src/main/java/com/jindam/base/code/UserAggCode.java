
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserAggCode implements CodeEnum {
    // 사용자 연령대 코드 : USAG

    USAG001("미확인", "AgeType.unknown"), //
    USAG002("10대 이하", "AgeType.teenUnder"), //
    USAG003("10대", "AgeType.teen"), //
    USAG004("20대", "AgeType.twenty"), //
    USAG005("30대", "AgeType.thirty"), //
    USAG006("40대", "AgeType.forty"), //
    USAG007("50대", "AgeType.fifty"), //
    USAG008("60대 이상", "AgeType.sixtyUpper"), //
    ;

    private final String text;
    private final String front;
}
