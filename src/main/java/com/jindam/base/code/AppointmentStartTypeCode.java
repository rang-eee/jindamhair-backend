
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppointmentStartTypeCode implements CodeEnum {
    // 예약 시작 유형 코드 : APSR

    byCustomer("고객 예약", "BeginMethodType.byCustomer"), //
    byDesigner("디자이너 예약", "BeginMethodType.byDesigner"), //
    changeByCustomer("고객에 의한 변경", "BeginMethodType.changeByCustomer"), //
    changeByDesigner("디자이너에 의한 변경", "BeginMethodType.changeByDesigner"), //
    reByCustomer("고객에 의한 재예약", "BeginMethodType.reByCustomer"), //
    reByDesigner("디자이너에 의한 재예약", "BeginMethodType.reByDesigner"), //
    offerByCustom("고객 제안을 통한 예약", "BeginMethodType.offerByCustom"), //
    ;

    private final String text;
    private final String front;
}
