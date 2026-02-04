package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ActionTypeCode implements CodeEnum {
	// 액션 유형 코드 : ACTP

	ACTP001("데이터 처리 없음", "ActionType.none"), //
	ACTP002("등록", "ActionType.regist"), //
	ACTP003("수정", "ActionType.modify"), //
	ACTP004("삭제", "ActionType.remove"), //
	;

	private final String text;
	private final String front;
}