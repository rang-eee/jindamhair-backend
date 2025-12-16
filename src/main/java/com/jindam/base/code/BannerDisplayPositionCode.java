
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum BannerDisplayPositionCode implements CodeEnum {
    // 배너 노출 위치 코드 : BDPT

    BDPT001("메인"), //
    BDPT002("공지"), //
    ;

    private final String text;
}
