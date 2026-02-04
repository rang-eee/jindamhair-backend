package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DesignerAccountBrandCode implements CodeEnum {
    // 디자이너 계정 브랜드 유형 코드 : DABT

    DABT001("미확인", "DesignerAccountBrandType.unknown"), //
    DABT002("국민은행", "DesignerAccountBrandType.kb"), //
    DABT003("신한은행", "DesignerAccountBrandType.shinhan"), //
    DABT004("농협은행", "DesignerAccountBrandType.nh"), //
    DABT005("기업은행", "DesignerAccountBrandType.ibk"), //
    DABT006("우리은행", "DesignerAccountBrandType.woori"), //
    DABT007("씨티은행", "DesignerAccountBrandType.city"), //
    DABT008("하나은행", "DesignerAccountBrandType.hana"), //
    DABT009("카카오뱅크", "DesignerAccountBrandType.kakao"), //
    DABT010("토스뱅크", "DesignerAccountBrandType.toss"), //
    DABT011("케이뱅크", "DesignerAccountBrandType.k"), //
    ;

    private final String text;
    private final String front;
}