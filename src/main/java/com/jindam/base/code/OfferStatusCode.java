
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum OfferStatusCode implements CodeEnum {
    // 제안 상태 코드 : OFST

    requested("고객 제안 요청", "OfferStatusType.requested"), //
    accepted("디자이너 수락 상태", "OfferStatusType.accepted"), //
    completed("고객 예약 완료", "OfferStatusType.completed"), //
    canceled("고객 제안 취소", "OfferStatusType.canceled"), //
    ;

    private final String text;
    private final String front;
}
