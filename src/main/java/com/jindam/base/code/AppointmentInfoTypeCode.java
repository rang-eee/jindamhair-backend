package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppointmentInfoTypeCode implements CodeEnum {
	// 예약 정보 유형 코드 : APIT

	unknown("미확인", "AppointmentInfoType.unknown"), //
	requested("요청", "AppointmentInfoType.requested"), //
	upcoming("예정", "AppointmentInfoType.upcoming"), //
	expired("경과", "AppointmentInfoType.expired"), //
	getting("진행", "AppointmentInfoType.getting"), //
	completed("완료", "AppointmentInfoType.completed"), //
	canceled("취소", "AppointmentInfoType.canceled"), //
	;

	private final String text;
	private final String front;
}