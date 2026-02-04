package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum FontFamilyTypeCode implements CodeEnum {
	// 폰트 패밀리 유형 코드 : FFTP

	FFTP001("Cafe24Ssurround", "FontFamilyType.Cafe24Ssurround"), //
	FFTP002("SUIT", "FontFamilyType.SUIT"), //
	FFTP003("SCDream", "FontFamilyType.SCDream"), //
	FFTP004("NotoSans", "FontFamilyType.NotoSans"), //
	;

	private final String text;
	private final String front;
}