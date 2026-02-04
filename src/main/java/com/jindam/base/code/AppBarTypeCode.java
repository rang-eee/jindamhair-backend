package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppBarTypeCode implements CodeEnum {
	// 앱바 유형 코드 : ABTP

	ABTP001("홈화면", "AppBarType.home"), //
	ABTP002("뒤로가기", "AppBarType.back"), //
	ABTP003("디자이너 상세 링크", "AppBarType.designerLink"), //
	ABTP004("채팅", "AppBarType.chat"), //
	ABTP005("알림", "AppBarType.notification"), //
	ABTP006("알림 전체읽기", "AppBarType.readNotification"), //
	ABTP007("알림 전체삭제", "AppBarType.deleteNotification"), //
	ABTP008("프로필", "AppBarType.profile"), //
	ABTP009("즐겨찾기", "AppBarType.favorite"), //
	ABTP010("즐겨찾기 제거", "AppBarType.favoriteMinus"), //
	;

	private final String text;
	private final String front;
}