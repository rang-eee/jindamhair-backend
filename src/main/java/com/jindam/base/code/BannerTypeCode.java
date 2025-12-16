package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum BannerTypeCode implements CodeEnum {
    // 배너 유형 코드 : BNTP

    BNTP001("배너"), //
    BNTP002("레이어팝업"), //
    ;

    private final String text;
}
