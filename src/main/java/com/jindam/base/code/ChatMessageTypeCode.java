
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ChatMessageTypeCode implements CodeEnum {
    // 채팅 메시지 유형 코드 : CMTP

    CMTP001("텍스트", "MessageType.text"), //
    CMTP002("이미지", "MessageType.image"), //
    CMTP003("동영상", "MessageType.video"), //
    CMTP004("파일", "MessageType.file"), //
    CMTP005("음원", "MessageType.sound"), //
    CMTP006("이모티콘", "MessageType.emoji"), //
    ;

    private final String text;
    private final String front;
}
