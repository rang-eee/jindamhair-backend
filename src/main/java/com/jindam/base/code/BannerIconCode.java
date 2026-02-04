package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerIconCode implements CodeEnum {
    // 배너 아이콘 코드 : BNIC

    BNIC001("없음", "IconType.none"), //
    BNIC002("공지사항", "IconType.notice"), //
    BNIC003("이벤트", "IconType.event"), //
    BNIC004("할인", "IconType.discount"), //
    BNIC005("일정", "IconType.calendar"), //
    BNIC006("가격 태그", "IconType.tag"), //
    ;

    private final String text;
    private final String front;
}