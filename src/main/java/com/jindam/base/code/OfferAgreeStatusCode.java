
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum OfferAgreeStatusCode implements CodeEnum {
    // 제안 수락 상태 코드 : OAST

    OAST001("대기", "CustomOfferRequestType.waiting"), //
    OAST002("수락", "CustomOfferRequestType.accepted"), //
    OAST003("거절", "CustomOfferRequestType.rejected"), //
    ;

    private final String text;
    private final String front;
}
