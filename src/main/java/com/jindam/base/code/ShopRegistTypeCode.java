
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum ShopRegistTypeCode implements CodeEnum {
    // 헤어샵 등록 유형 코드 : SRTP

    SRTP001("관리자 등록"), //
    SRTP002("디자이너 등록"), //
    ;

    private final String text;
}
