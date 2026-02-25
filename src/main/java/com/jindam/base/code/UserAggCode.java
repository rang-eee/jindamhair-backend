
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserAggCode implements CodeEnum {
    // 사용자 연령대 코드 : USAG

    unknown("미확인", "AgeType.unknown"), //
    teenUnder("10대 이하", "AgeType.teenUnder"), //
    teen("10대", "AgeType.teen"), //
    twenty("20대", "AgeType.twenty"), //
    thirty("30대", "AgeType.thirty"), //
    forty("40대", "AgeType.forty"), //
    fifty("50대", "AgeType.fifty"), //
    sixtyUpper("60대 이상", "AgeType.sixtyUpper"), //
    ;

    private final String text;
    private final String front;
}
