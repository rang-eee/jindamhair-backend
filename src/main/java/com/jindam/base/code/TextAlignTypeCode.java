package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum TextAlignTypeCode implements CodeEnum {
	// 텍스트 정렬 유형 코드 : TATP

	center("중앙", "TextAlignType.center"), //
	left("왼쪽", "TextAlignType.left"), //
	right("오른쪽", "TextAlignType.right"), //
	;

	private final String text;
	private final String front;
}