package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerIconCode implements CodeEnum {
    // 배너 아이콘 코드 : BNIC

    none("없음", "IconType.none"), //
    notice("공지사항", "IconType.notice"), //
    event("이벤트", "IconType.event"), //
    discount("할인", "IconType.discount"), //
    calendar("일정", "IconType.calendar"), //
    tag("가격 태그", "IconType.tag"), //
    ;

    private final String text;
    private final String front;
}