
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum OfferAgreeStatusCode implements CodeEnum {
    // 제안 수락 상태 코드 : OAST

    OAST001("대기"), //
    OAST002("수락"), //
    OAST003("거절"), //
    ;

    private final String text;
}
