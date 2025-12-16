package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum BannerDisplayTargetCode implements CodeEnum {
    // 배너 노출 대상 코드 : BDTG

    BDTG001("전체"), //
    BDTG002("고객"), //
    BDTG003("디자이너"), //
    ;

    private final String text;
}
