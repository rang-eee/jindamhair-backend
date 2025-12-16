package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum BannerIconCode implements CodeEnum {
    // 배너 아이콘 코드 : BNIC

    BNIC001("없음"), //
    BNIC002("공지사항"), //
    BNIC003("이벤트"), //
    BNIC004("할인"), //
    BNIC005("일정"), //
    BNIC006("가격 태그"), //
    ;

    private final String text;
}