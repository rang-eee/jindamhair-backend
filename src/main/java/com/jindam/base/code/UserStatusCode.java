
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserStatusCode implements CodeEnum {
    // 사용자 상태 코드 : USST

    USST001("미확인", "UserStatusType.unknown"), //
    USST002("임시 가입", "UserStatusType.temp"), //
    USST003("가입 완료", "UserStatusType.active"), //
    USST004("휴면", "UserStatusType.dormant"), //
    USST005("탈회", "UserStatusType.withdrawn"), //
    USST006("블랙리스트", "UserStatusType.blacklisted"), //
    USST007("관리자 삭제", "UserStatusType.removed"), //
    ;

    private final String text;
    private final String front;
}