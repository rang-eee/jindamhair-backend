package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BottomNavItemCode implements CodeEnum {
	// 하단 네비게이션 아이템 코드 : BNIT

	BNIT001("디자이너 홈", "BottomNavItem.DesignerHome"), //
	BNIT002("디자이너", "BottomNavItem.DesignerSearch"), //
	BNIT003("가격 제안", "BottomNavItem.Offer"), //
	BNIT004("채팅", "BottomNavItem.Chat"), //
	BNIT005("프로필", "BottomNavItem.Profile"), //
	;

	private final String text;
	private final String front;
}