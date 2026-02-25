package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum PolicyTypeCode implements CodeEnum {
	// 정책 유형 코드 : PLTP

	privacy("개인정보처리방침", "PolicyType.privacy"), //
	terms("서비스 이용약관", "PolicyType.terms"), //
	termsDesigner("서비스 이용약관(디자이너)", "PolicyType.termsDesigner"), //
	;

	private final String text;
	private final String front;
}