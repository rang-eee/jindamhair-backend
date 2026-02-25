
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ReviewTypeCode implements CodeEnum {
    // 후기 유형 코드 : RVTP

    friendlyService("친절한 서비스", "ReviewType.friendlyService"), //
    professionalSkill("전문적인 시술 실력", "ReviewType.professionalSkill"), //
    greatStyling("스타일 완성도/만족", "ReviewType.greatStyling"), //
    goodCommunication("상담/소통 만족", "ReviewType.goodCommunication"), //
    ;

    private final String text;
    private final String front;
}
