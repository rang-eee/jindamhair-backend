package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DesignerAccountBrandCode implements CodeEnum {
    // 디자이너 계정 브랜드 유형 코드 : DABT

    unknown("미확인", "DesignerAccountBrandType.unknown"), //
    kb("국민은행", "DesignerAccountBrandType.kb"), //
    shinhan("신한은행", "DesignerAccountBrandType.shinhan"), //
    nh("농협은행", "DesignerAccountBrandType.nh"), //
    ibk("기업은행", "DesignerAccountBrandType.ibk"), //
    woori("우리은행", "DesignerAccountBrandType.woori"), //
    city("씨티은행", "DesignerAccountBrandType.city"), //
    hana("하나은행", "DesignerAccountBrandType.hana"), //
    kakao("카카오뱅크", "DesignerAccountBrandType.kakao"), //
    toss("토스뱅크", "DesignerAccountBrandType.toss"), //
    k("케이뱅크", "DesignerAccountBrandType.k"), //
    ;

    private final String text;
    private final String front;
}