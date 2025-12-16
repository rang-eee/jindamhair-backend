
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum HairAddTypeCode implements CodeEnum {
    // 헤어 추가 유형 코드 : HATP

    HATP001("기본"), //
    HATP002("턱선 아래"), //
    HATP003("어깨선 아래"), //
    HATP004("가슴선 아래"), //
    HATP005("허리선 아래"), //
    ;

    private final String text;
}
