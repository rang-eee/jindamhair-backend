
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ChatMessageTypeCode implements CodeEnum {
    // 채팅 메시지 유형 코드 : CMTP

    txt("텍스트", "MessageType.text"), //
    image("이미지", "MessageType.image"), //
    video("동영상", "MessageType.video"), //
    file("파일", "MessageType.file"), //
    sound("음원", "MessageType.sound"), //
    emoji("이모티콘", "MessageType.emoji"), //
    ;

    private final String text;
    private final String front;
}
