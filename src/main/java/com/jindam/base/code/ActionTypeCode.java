package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ActionTypeCode implements CodeEnum {
	// 액션 유형 코드 : ACTP

	none("데이터 처리 없음", "ActionType.none"), //
	regist("등록", "ActionType.regist"), //
	modify("수정", "ActionType.modify"), //
	remove("삭제", "ActionType.remove"), //
	;

	private final String text;
	private final String front;
}