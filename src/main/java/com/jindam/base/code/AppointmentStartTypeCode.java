
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppointmentStartTypeCode implements CodeEnum {
    // 예약 시작 유형 코드 : APSR

    APSR001("고객 예약", "BeginMethodType.byCustomer"), //
    APSR002("디자이너 예약", "BeginMethodType.byDesigner"), //
    APSR003("고객에 의한 변경", "BeginMethodType.changeByCustomer"), //
    APSR004("디자이너에 의한 변경", "BeginMethodType.changeByDesigner"), //
    APSR005("고객에 의한 재예약", "BeginMethodType.reByCustomer"), //
    APSR006("디자이너에 의한 재예약", "BeginMethodType.reByDesigner"), //
    APSR007("고객 제안을 통한 예약", "BeginMethodType.offerByCustom"), //
    ;

    private final String text;
    private final String front;
}
