
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserGenderCode implements CodeEnum {
    // 사용자 성별 코드 : USGD

    USGD001("여성", "GenderType.female"), //
    USGD002("남성", "GenderType.male"), //
    ;

    private final String text;
    private final String front;
}