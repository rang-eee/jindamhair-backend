package com.jindam.app.common.exception;

import com.jindam.base.base.ApiResultCode;
import com.jindam.base.base.BaseReason;
import com.jindam.base.base.MasterException;
import com.jindam.base.message.Message;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 공통 예외 처리 클래스
 * 
 * 공통적으로 발생할 수 있는 예외 상황들을 정의하며, 각 예외는 `MasterException`을 상속받아 공통적인 예외 처리 방식을 유지합니다.
 */
public class CommonException extends MasterException {

    /**
     * 공통 예외 사유를 정의하는 열거형
     * 
     * 
     * 이 열거형은 `BaseReason` 인터페이스를 구현하며, 예외 코드와 메시지를 포함합니다.
     * 
     * 각 상수는 특정 예외 상황에 대한 설명과 해당 메시지를 제공합니다.
     */
    @Getter
    @AllArgsConstructor
    public enum Reason implements BaseReason {
        FAIL(ApiResultCode.Common.FAIL.getCode(), "common.proc.failed"), // 공통 - 서비스 로직 상의 오류
        NOT_VALID(ApiResultCode.Common.NOT_VALID.getCode(), "common.proc.failed.notValid"), // HttpStatus 400 입력 값에 대한 유효성 검증을 통과하지 못한 케이스
        REQUIRED_AUTHENTICATION(ApiResultCode.Common.REQUIRED_AUTHENTICATION.getCode(), "common.auth.required"), // HttpStatus 401(인증 필요) 에러 케이스
        FORBIDDEN(ApiResultCode.Common.FORBIDDEN.getCode(), "common.auth.forbidden"), // HttpStatus 403(권한 없음) 에러 케이스
        NOT_FOUND(ApiResultCode.Common.NOT_FOUND.getCode(), "common.proc.failed.invalidUrl"), // HttpStatus 404(존재하지 않는 리소스) 에러 케이스
        METHOD_NOT_ALLOWED(ApiResultCode.Common.METHOD_NOT_ALLOWED.getCode(), "common.proc.failed.invalidMethod"), // HttpStatus 405(허용되지 않는 메소드) 에러 케이스
        TOO_LARGE(ApiResultCode.Common.TOO_LARGE.getCode(), "common.proc.failed.uploadSize"), // HttpStatus 413(요청 데이터 용량 초과) 에러 케이스
        UNSUPPORTED_TYPE(ApiResultCode.Common.UNSUPPORTED_TYPE.getCode(), "common.proc.failed.uploadSize"), // HttpStatus 415(지원하지 않는 콘텐츠 유형) 에러 케이스
        DUPLICATE(ApiResultCode.Common.DUPLICATE.getCode(), "common.proc.failed.duplicate"), // Database Duplicate 에러
        ;

        private final Integer code; // 예외 코드
        private final String messageKey; // 예외 메시지

        @Override
        public String getMessage() {
            return messageKey != null ? Message.getMessage(messageKey) : null;
        }
    }

    /**
     * 생성자: 주어진 `Reason`을 기반으로 예외를 생성합니다.
     * 
     * @param reason 예외의 원인을 설명하는 `Reason` 객체
     */
    public CommonException(Reason reason) {
        super(reason);
    }
}
