package com.jindam.base.code;

import java.util.List;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerDisplayTargetCode implements CodeEnum {
    // 배너 노출 대상 코드 : BDTG

    all("전체", "DisplayTargetUserType.all", List.of("all")), //
customer("고객", "DisplayTargetUserType.customer", List.of("all", "customer")), //
    designer("디자이너", "DisplayTargetUserType.designer", List.of("all", "designer")), //
    ;

    private final String text;
    private final String front;

    /**
     * 해당 타겟 조회 시 포함할 타겟 코드 배열 (enum name 기준). 예: customer → {"customer", "all"} → SQL IN 절로 처리.
     */
    private final List<String> includeTargetCodes;
}
