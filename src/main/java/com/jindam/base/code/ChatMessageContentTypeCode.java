
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ChatMessageContentTypeCode implements CodeEnum {
    // 채팅 메시지 내용 유형 코드 : CMCT

    basic("기본", "MessageTextType.basic"), //
    review("후기", "MessageTextType.review"), //
    ;

    private final String text;
    private final String front;
}