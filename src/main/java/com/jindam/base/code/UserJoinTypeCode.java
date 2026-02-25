
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserJoinTypeCode implements CodeEnum {
    // 사용자 가입 유형 코드 : UJTP

    email("이메일", "SignUpMethodType.email"), //
    apple("애플", "SignUpMethodType.apple"), //
    google("구글", "SignUpMethodType.google"), //
    facebook("페이스북", "SignUpMethodType.facebook"), //
    kakao("카카오", "SignUpMethodType.kakao"), //
    naver("네이버", "SignUpMethodType.naver"), //
    ;

    private final String text;
    private final String front;
}
