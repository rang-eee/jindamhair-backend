
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum DesignerWorkStatusCode implements CodeEnum {
    // 디자이너 근무 상태 코드 : DWST

    DWST001("정상근무"), //
    DWST002("휴무"), //
    ;

    private final String text;
}