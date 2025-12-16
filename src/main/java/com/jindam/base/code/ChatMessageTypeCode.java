
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum ChatMessageTypeCode implements CodeEnum {
    // 채팅 메시지 유형 코드 : CMTP

    CMTP001("텍스트"), //
    CMTP002("이미지"), //
    CMTP003("동영상"), //
    CMTP004("파일"), //
    CMTP005("음원"), //
    CMTP006("이모티콘"), //
    ;

    private final String text;
}
