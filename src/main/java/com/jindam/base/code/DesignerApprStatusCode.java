
package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;
import com.jindam.base.code.handler.CodeEnum;

@Getter
@AllArgsConstructor
public enum DesignerApprStatusCode implements CodeEnum {
    // 디자이너 승인 상태 코드 : DAST

    DAST001("미인증"), //
    DAST002("승인"), //
    DAST003("거절"), //
    DAST004("대기"), //
    ;

    private final String text;
}
