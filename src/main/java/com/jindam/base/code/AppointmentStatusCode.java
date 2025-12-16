package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum AppointmentStatusCode implements CodeEnum {
    // 예약 상태 코드 : APST

    APST001("시간선택"), //
    APST002("결제방법선택"), //
    APST003("예약불가"), //
    APST004("예약요청"), //
    APST005("예약완료"), //
    APST006("시술중"), //
    APST007("시술완료"), //
    APST008("예약취소"), //
    APST009("후기작성완료"), //
    ;

    private final String text;
}
