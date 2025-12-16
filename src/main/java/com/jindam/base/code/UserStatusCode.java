
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum UserStatusCode implements CodeEnum {
    // 사용자 상태 코드 : USST

    USST001("미확인"), //
    USST002("임시 가입"), //
    USST003("가입 완료"), //
    USST004("휴면"), //
    USST005("탈회"), //
    USST006("블랙리스트"), //
    USST007("관리자 삭제"), //
    ;

    private final String text;
}