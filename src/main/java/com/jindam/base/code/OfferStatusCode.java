
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum OfferStatusCode implements CodeEnum {
    // 제안 상태 코드 : OFST

    OFST001("고객 제안 요청", "OfferStatusType.requested"), //
    OFST002("디자이너 수락 상태", "OfferStatusType.accepted"), //
    OFST003("고객 예약 완료", "OfferStatusType.completed"), //
    OFST004("고객 제안 취소", "OfferStatusType.canceled"), //
    ;

    private final String text;
    private final String front;
}
