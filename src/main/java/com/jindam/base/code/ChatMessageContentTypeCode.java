
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum ChatMessageContentTypeCode implements CodeEnum {
    // 채팅 메시지 내용 유형 코드 : CMCT

    CMCT001("기본"), //
    CMCT002("후기"), //
    ;

    private final String text;
}