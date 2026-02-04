
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum HairAddTypeCode implements CodeEnum {
    // 헤어 추가 유형 코드 : HATP

    HATP001("기본", "HairAddType.basic"), //
    HATP002("턱선 아래", "HairAddType.chinLine"), //
    HATP003("어깨선 아래", "HairAddType.shoulderLine"), //
    HATP004("가슴선 아래", "HairAddType.chestLine"), //
    HATP005("허리선 아래", "HairAddType.waistLine"), //
    ;

    private final String text;
    private final String front;
}
