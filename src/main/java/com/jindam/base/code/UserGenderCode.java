
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum UserGenderCode implements CodeEnum {
    // 사용자 성별 코드 : USGD

    USGD001("여성"), //
    USGD002("남성"), //
    ;

    private final String text;
}