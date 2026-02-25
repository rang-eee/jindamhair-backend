package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppointmentCurrentTypeCode implements CodeEnum {
	// 예약 현재 상태 유형 코드 : APCT

	unknown("미확인", "AppointmentCurrentType.unknown"), //
	enable("예약 가능", "AppointmentCurrentType.enable"), //
	disabled("예약 불가", "AppointmentCurrentType.disabled"), //
	completed("예약 완료", "AppointmentCurrentType.completed"), //
	getting("시술중", "AppointmentCurrentType.getting"), //
	finished("시술 완료", "AppointmentCurrentType.finished"), //
	;

	private final String text;
	private final String front;
}