package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum AppBarTypeCode implements CodeEnum {
	// 앱바 유형 코드 : ABTP

	home("홈화면", "AppBarType.home"), //
	back("뒤로가기", "AppBarType.back"), //
	designerLink("디자이너 상세 링크", "AppBarType.designerLink"), //
	chat("채팅", "AppBarType.chat"), //
	notification("알림", "AppBarType.notification"), //
	readNotification("알림 전체읽기", "AppBarType.readNotification"), //
	deleteNotification("알림 전체삭제", "AppBarType.deleteNotification"), //
	profile("프로필", "AppBarType.profile"), //
	favorite("즐겨찾기", "AppBarType.favorite"), //
	favoriteMinus("즐겨찾기 제거", "AppBarType.favoriteMinus"), //
	;

	private final String text;
	private final String front;
}