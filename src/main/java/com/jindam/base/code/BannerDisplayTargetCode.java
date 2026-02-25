package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerDisplayTargetCode implements CodeEnum {
    // 배너 노출 대상 코드 : BDTG

    all("전체", "DisplayTargetUserType.all"), //
    customer("고객", "DisplayTargetUserType.customer"), //
    designer("디자이너", "DisplayTargetUserType.designer"), //
    ;

    private final String text;
    private final String front;
}
