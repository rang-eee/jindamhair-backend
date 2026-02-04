package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerDisplayTargetCode implements CodeEnum {
    // 배너 노출 대상 코드 : BDTG

    BDTG001("전체", "DisplayTargetUserType.all"), //
    BDTG002("고객", "DisplayTargetUserType.customer"), //
    BDTG003("디자이너", "DisplayTargetUserType.designer"), //
    ;

    private final String text;
    private final String front;
}
