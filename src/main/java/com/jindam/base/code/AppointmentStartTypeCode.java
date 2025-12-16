
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum AppointmentStartTypeCode implements CodeEnum {
    // 예약 시작 유형 코드 : APSR

    APSR001("고객 예약"), //
    APSR002("디자이너 예약"), //
    APSR003("고객에 의한 변경"), //
    APSR004("디자이너에 의한 변경"), //
    APSR005("고객에 의한 재예약"), //
    APSR006("디자이너에 의한 재예약"), //
    APSR007("고객 제안을 통한 예약"), //
    ;

    private final String text;
}
