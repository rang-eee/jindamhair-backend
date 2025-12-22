package com.jindam.app.appointment.exception;

import com.jindam.base.base.ApiResultCode;
import com.jindam.base.base.BaseReason;
import com.jindam.base.base.MasterException;
import com.jindam.base.message.Message;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * User API의 예외 처리 클래스
 *
 * User API에서 발생할 수 있는 예외 상황들을 정의하며, 각 예외는 `MasterException`을 상속받아 공통적인 예외 처리 방식을 유지합니다.
 */
public class AppointmentException extends MasterException {

    /**
     * User API 예외 사유를 정의하는 열거형
     *
     *
     * 이 열거형은 `BaseReason` 인터페이스를 구현하며, 예외 코드와 메시지를 포함합니다.
     *
     * 각 상수는 특정 예외 상황에 대한 설명과 해당 메시지를 제공합니다.
     */
    @Getter
    @AllArgsConstructor
    public enum Reason implements BaseReason {
        INVALID_REQUEST(ApiResultCode.User.INVALID_REQUEST.getCode(), Message.getMessage("example.invalid.request")), // 요청 파라미터 이상
        INVALID_ID(ApiResultCode.User.INVALID_ID.getCode(), Message.getMessage("example.invalid.id")), // 유효하지 않은 아이디
        NOT_EXIST_NAME(ApiResultCode.User.NOT_EXIST_NAME.getCode(), Message.getMessage("example.not.exist.name")), // 존재하지 않는 이름
        DUPLICATE_ID(ApiResultCode.User.DUPLICATE_ID.getCode(), Message.getMessage("example.duplicate.id")); // 중복된 아이디 존재

        private final Integer code; // 예외 코드
        private final String message; // 예외 메시지
    }

    /**
     * 생성자: 주어진 `Reason`을 기반으로 예외를 생성합니다.
     *
     * @param reason 예외의 원인을 설명하는 `Reason` 객체
     */
    public AppointmentException(Reason reason) {
        super(reason);
    }

    /**
     * 생성자: 주어진 `Reason`을 기반으로 예외를 생성합니다.
     *
     * @param reason 예외의 원인을 설명하는 `Reason` 객체
     */
    public AppointmentException(Reason reason, String customMessage) {
        super(reason, customMessage);
    }

    /**
     * 생성자: 주어진 `Reason`을 기반으로 예외를 생성합니다.
     *
     * @param reason 예외의 원인을 설명하는 `Reason` 객체
     */
    public AppointmentException(Reason reason, String prefix, String suffix) {
        super(reason, prefix, suffix);
    }

}
