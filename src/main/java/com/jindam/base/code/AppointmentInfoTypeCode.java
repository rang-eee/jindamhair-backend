package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppointmentInfoTypeCode implements CodeEnum {
	// 예약 정보 유형 코드 : APIT

	APIT001("미확인", "AppointmentInfoType.unknown"), //
	APIT002("요청", "AppointmentInfoType.requested"), //
	APIT003("예정", "AppointmentInfoType.upcoming"), //
	APIT004("경과", "AppointmentInfoType.expired"), //
	APIT005("진행", "AppointmentInfoType.getting"), //
	APIT006("완료", "AppointmentInfoType.completed"), //
	APIT007("취소", "AppointmentInfoType.canceled"), //
	;

	private final String text;
	private final String front;
}