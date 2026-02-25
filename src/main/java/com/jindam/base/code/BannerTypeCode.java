package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerTypeCode implements CodeEnum {
    // 배너 유형 코드 : BNTP

    banner("배너", "BannerType.banner"), //
    layer("레이어팝업", "BannerType.layer"), //
    ;

    private final String text;
    private final String front;
}
