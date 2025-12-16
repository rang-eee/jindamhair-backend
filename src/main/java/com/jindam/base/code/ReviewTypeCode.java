
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum ReviewTypeCode implements CodeEnum {
    // 후기 유형 코드 : RVTP

    RVTP001("친절한 서비스"), //
    RVTP002("전문적인 시술 실력"), //
    RVTP003("스타일 완성도/만족"), //
    RVTP004("상담/소통 만족"), //
    ;

    private final String text;
}
