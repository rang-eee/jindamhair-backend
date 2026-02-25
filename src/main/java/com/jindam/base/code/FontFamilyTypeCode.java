package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum FontFamilyTypeCode implements CodeEnum {
	// 폰트 패밀리 유형 코드 : FFTP

	Cafe24Ssurround("Cafe24Ssurround", "FontFamilyType.Cafe24Ssurround"), //
	SUIT("SUIT", "FontFamilyType.SUIT"), //
	SCDream("SCDream", "FontFamilyType.SCDream"), //
	NotoSans("NotoSans", "FontFamilyType.NotoSans"), //
	;

	private final String text;
	private final String front;
}