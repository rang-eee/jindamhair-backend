
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserJoinTypeCode implements CodeEnum {
    // 사용자 가입 유형 코드 : UJTP

    UJTP001("이메일", "SignUpMethodType.email"), //
    UJTP002("애플", "SignUpMethodType.apple"), //
    UJTP003("구글", "SignUpMethodType.google"), //
    UJTP004("페이스북", "SignUpMethodType.facebook"), //
    UJTP005("카카오", "SignUpMethodType.kakao"), //
    UJTP006("네이버", "SignUpMethodType.naver"), //
    ;

    private final String text;
    private final String front;
}
