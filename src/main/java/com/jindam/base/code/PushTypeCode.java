
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum PushTypeCode implements CodeEnum {
    // 푸시 유형 코드 : PSTP

    chat("채팅", "PushType.chat"), //
    appointment("예약", "PushType.appointment"), //
    recommand("추천", "PushType.recommand"), //
    ;

    private final String text;
    private final String front;
}
