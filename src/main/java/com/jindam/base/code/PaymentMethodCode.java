
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum PaymentMethodCode implements CodeEnum {
    // 결제 방법 코드 : PMMT

    onSitePayment("현장결제", "PaymentMethodType.onSitePayment"), //
    inAppPayment("온라인결제", "PaymentMethodType.inAppPayment"), //
    ;

    private final String text;
    private final String front;
}
