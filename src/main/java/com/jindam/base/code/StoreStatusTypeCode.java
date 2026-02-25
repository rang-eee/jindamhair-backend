package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum StoreStatusTypeCode implements CodeEnum {
	// 매장 상태 유형 코드 : SSTP

	active("정상", "StoreStatusType.active"), //
	unused("미사용", "StoreStatusType.unused"), //
	delete("삭제", "StoreStatusType.delete"), //
	;

	private final String text;
	private final String front;
}