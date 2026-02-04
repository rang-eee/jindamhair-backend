package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppointmentCurrentTypeCode implements CodeEnum {
	// 예약 현재 상태 유형 코드 : APCT

	APCT001("미확인", "AppointmentCurrentType.unknown"), //
	APCT002("예약 가능", "AppointmentCurrentType.enable"), //
	APCT003("예약 불가", "AppointmentCurrentType.disabled"), //
	APCT004("예약 완료", "AppointmentCurrentType.completed"), //
	APCT005("시술중", "AppointmentCurrentType.getting"), //
	APCT006("시술 완료", "AppointmentCurrentType.finished"), //
	;

	private final String text;
	private final String front;
}