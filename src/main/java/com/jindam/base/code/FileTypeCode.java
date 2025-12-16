
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum FileTypeCode implements CodeEnum {
    // 파일 유형 코드 : FLTP

    FLTP001("이미지"), //
    FLTP002("동영상"), //
    FLTP003("PDF"), //
    FLTP004("텍스트"), //
    ;

    private final String text;
}
