
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum FileTypeCode implements CodeEnum {
    // 파일 유형 코드 : FLTP

    FLTP001("이미지", "FileType.image"), //
    FLTP002("동영상", "FileType.movie"), //
    FLTP003("PDF", "FileType.pdf"), //
    FLTP004("텍스트", "FileType.text"), //
    ;

    private final String text;
    private final String front;
}
