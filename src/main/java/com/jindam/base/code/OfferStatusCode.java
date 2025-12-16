
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum OfferStatusCode implements CodeEnum {
    // 제안 상태 코드 : OFST

    OFST001("고객 제안 요청"), //
    OFST002("디자이너 수락 상태"), //
    OFST003("고객 예약 완료"), //
    OFST004("고객 제안 취소"), //
    ;

    private final String text;
}
