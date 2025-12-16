
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum PaymentMethodCode implements CodeEnum {
    // 결제 방법 코드 : PMMT

    PMMT001("현장결제"), //
    PMMT002("온라인결제"), //
    ;

    private final String text;
}
