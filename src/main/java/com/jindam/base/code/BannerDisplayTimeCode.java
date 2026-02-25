
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerDisplayTimeCode implements CodeEnum {
    // 배너 노출 시간 코드 : BDTM

    always("항상", "DisplayTimeType.always"), //
    date("시간 조건", "DisplayTimeType.date"), //
    ;

    private final String text;
    private final String front;
}
