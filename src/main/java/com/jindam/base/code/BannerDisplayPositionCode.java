
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum BannerDisplayPositionCode implements CodeEnum {
    // 배너 노출 위치 코드 : BDPT

    main("메인", "DisplayPositionType.main"), //
    notice("공지", "DisplayPositionType.notice"), //
    customerList("고객목록", "DisplayPositionType.customerList"), //
    ;

    private final String text;
    private final String front;
}
