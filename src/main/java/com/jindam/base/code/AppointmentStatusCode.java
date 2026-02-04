package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppointmentStatusCode implements CodeEnum {
    // 예약 상태 코드 : APST

    APST001("시간선택", "AppointmentStatusType.selectTime"), //
    APST002("결제방법선택", "AppointmentStatusType.selectPayment"), //
    APST003("예약불가", "AppointmentStatusType.disabled"), //
    APST004("예약요청", "AppointmentStatusType.requested"), //
    APST005("예약완료", "AppointmentStatusType.completed"), //
    APST006("시술중", "AppointmentStatusType.getting"), //
    APST007("시술완료", "AppointmentStatusType.finished"), //
    APST008("예약취소", "AppointmentStatusType.canceled"), //
    APST009("후기작성완료", "AppointmentStatusType.reviewed"), //
    ;

    private final String text;
    private final String front;
}
