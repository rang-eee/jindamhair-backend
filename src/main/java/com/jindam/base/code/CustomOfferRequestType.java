package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum CustomOfferRequestType implements CodeEnum {
    // 커스텀 제안 요청 유형 : CORT

    unknown("미확인", "CustomOfferRequestType.unknown"), //
    waiting("대기", "CustomOfferRequestType.waiting"), //
    accepted("수락", "CustomOfferRequestType.accepted"), //
    rejected("거절", "CustomOfferRequestType.rejected"), //
    ;

    private final String text;
    private final String front;
}
