package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppointmentStatusCode implements CodeEnum {
    // 예약 상태 코드 : APST

    selectTime("시간선택", "AppointmentStatusType.selectTime"), //
    selectPayment("결제방법선택", "AppointmentStatusType.selectPayment"), //
    disabled("예약불가", "AppointmentStatusType.disabled"), //
    requested("예약요청", "AppointmentStatusType.requested"), //
    completed("예약완료", "AppointmentStatusType.completed"), //
    getting("시술중", "AppointmentStatusType.getting"), //
    finished("시술완료", "AppointmentStatusType.finished"), //
    canceled("예약취소", "AppointmentStatusType.canceled"), //
    reviewed("후기작성완료", "AppointmentStatusType.reviewed"), //
    ;

    private final String text;
    private final String front;
}
