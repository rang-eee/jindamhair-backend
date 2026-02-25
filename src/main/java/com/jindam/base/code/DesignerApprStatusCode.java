
package com.jindam.base.code;

import com.jindam.base.code.handler.CodeEnum;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum DesignerApprStatusCode implements CodeEnum {
    // 디자이너 승인 상태 코드 : DAST

    preAuth("미인증", "DesignerAuthStatusType.preAuth"), //
    authComplete("승인", "DesignerAuthStatusType.authComplete"), //
    authReject("거절", "DesignerAuthStatusType.authReject"), //
    authWait("대기", "DesignerAuthStatusType.authWait"), //
    ;

    private final String text;
    private final String front;
}
