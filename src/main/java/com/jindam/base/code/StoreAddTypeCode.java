package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum StoreAddTypeCode implements CodeEnum {
	// 매장 등록 유형 코드 : SATP

	SATP001("기본 매장", "StoreAddType.basic"), //
	SATP002("추가 매장", "StoreAddType.add"), //
	;

	private final String text;
	private final String front;
}