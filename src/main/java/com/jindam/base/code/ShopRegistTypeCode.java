
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum ShopRegistTypeCode implements CodeEnum {
    // 헤어샵 등록 유형 코드 : SRTP

    basic("관리자 등록", "StoreAddType.basic"), //
    add("디자이너 등록", "StoreAddType.add"), //
    ;

    private final String text;
    private final String front;
}
