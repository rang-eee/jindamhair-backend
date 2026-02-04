
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum TreatmentGenderTypeCode implements CodeEnum {
    // 시술 성별 유형 코드 : TGTP

    TGTP001("전체", ""), //
    TGTP002("여성", "GenderType.female"), //
    TGTP003("남성", "GenderType.male"), //
    ;

    private final String text;
    private final String front;
}