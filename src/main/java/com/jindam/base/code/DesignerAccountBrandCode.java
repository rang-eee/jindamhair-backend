package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DesignerAccountBrandCode implements CodeEnum {
    // 디자이너 계정 브랜드 유형 코드 : DABT

    DABT001("미확인"), //
    DABT002("국민은행"), //
    DABT003("신한은행"), //
    DABT004("농협은행"), //
    DABT005("기업은행"), //
    DABT006("우리은행"), //
    DABT007("씨티은행"), //
    DABT008("하나은행"), //
    DABT009("카카오뱅크"), //
    DABT010("토스뱅크"), //
    DABT011("케이뱅크"), //
    ;

    private final String text;
}