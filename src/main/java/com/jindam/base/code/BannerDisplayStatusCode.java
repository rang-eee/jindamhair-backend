
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerDisplayStatusCode implements CodeEnum {
    // 배너 노출 상태 코드 : BDST

    visible("노출", "DisplayType.visible"), //
    hidden("미노출", "DisplayType.hidden"), //
    ;

    private final String text;
    private final String front;
}
