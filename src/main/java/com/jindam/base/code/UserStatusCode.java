
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserStatusCode implements CodeEnum {
    // 사용자 상태 코드 : USST

    unknown("미확인", "UserStatusType.unknown"), //
    temp("임시 가입", "UserStatusType.temp"), //
    active("가입 완료", "UserStatusType.active"), //
    dormant("휴면", "UserStatusType.dormant"), //
    withdrawn("탈회", "UserStatusType.withdrawn"), //
    blacklisted("블랙리스트", "UserStatusType.blacklisted"), //
    removed("관리자 삭제", "UserStatusType.removed"), //
    ;

    private final String text;
    private final String front;
}