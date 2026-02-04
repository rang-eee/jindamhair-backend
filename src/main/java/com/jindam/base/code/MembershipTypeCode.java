package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum MembershipTypeCode implements CodeEnum {
	// 멤버십 유형 코드 : MBTP

	MBTP001("일반", "MembershipType.normal"), //
	MBTP002("프리미엄", "MembershipType.premium"), //
	;

	private final String text;
	private final String front;
}