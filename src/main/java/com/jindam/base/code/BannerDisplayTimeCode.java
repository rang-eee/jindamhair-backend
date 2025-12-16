
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum BannerDisplayTimeCode implements CodeEnum {
    // 배너 노출 시간 코드 : BDTM

    BDTM001("항상"), //
    BDTM002("시간 조건"), //
    ;

    private final String text;
}
