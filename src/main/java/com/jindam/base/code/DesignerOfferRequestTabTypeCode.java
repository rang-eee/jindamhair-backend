package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DesignerOfferRequestTabTypeCode implements CodeEnum {
	// 디자이너 제안 요청 탭 유형 코드 : DORT

	DORT001("미확인", "DesignerOfferRequestTabType.unknown"), //
	DORT002("요청", "DesignerOfferRequestTabType.requested"), //
	DORT003("완료", "DesignerOfferRequestTabType.completed"), //
	;

	private final String text;
	private final String front;
}