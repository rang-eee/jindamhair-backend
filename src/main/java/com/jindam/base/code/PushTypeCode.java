
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum PushTypeCode implements CodeEnum {
    // 푸시 유형 코드 : PSTP

    PSTP001("채팅"), //
    PSTP002("예약"), //
    PSTP003("추천"), //
    ;

    private final String text;
}
