
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum BannerDisplayStatusCode implements CodeEnum {
    // 배너 노출 상태 코드 : BDST

    BDST001("노출"), //
    BDST002("미노출"), //
    ;

    private final String text;
}
