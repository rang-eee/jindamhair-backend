
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ReviewTypeCode implements CodeEnum {
    // 후기 유형 코드 : RVTP

    RVTP001("친절한 서비스", "ReviewType.friendlyService"), //
    RVTP002("전문적인 시술 실력", "ReviewType.professionalSkill"), //
    RVTP003("스타일 완성도/만족", "ReviewType.greatStyling"), //
    RVTP004("상담/소통 만족", "ReviewType.goodCommunication"), //
    ;

    private final String text;
    private final String front;
}
