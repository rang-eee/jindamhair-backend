package com.jindam.base.base;

import com.jindam.util.StringUtils;

import lombok.Getter;
import lombok.Setter;

/**
 * API 예외 처리를 위한 추상 클래스
 * 
 * 모든 커스텀 예외는 이 클래스를 상속받아 공통적인 예외 처리 로직을 재사용할 수 있습니다. <br>
 * 각 예외는 `BaseReason` 인터페이스를 구현하여 예외의 코드와 메시지를 제공해야 합니다.
 */
@Getter
@Setter
public abstract class MasterException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    private final BaseReason reason; // 예외의 원인을 설명하는 BaseReason 객체

    private final String messagePrefix; // 예외 메시지 이전 텍스트. 동적 메시지를 위해 사용

    private final String messageSuffix; // 예외 메시지 이후 텍스트. 동적 메시지를 위해 사용

    private final String customMessage; // 예외 메시지. 동적 메시지를 위해 사용

    /**
     * 생성자: 예외의 원인(`reason`)을 기반으로 예외를 생성합니다.
     * 
     * @param reason 예외의 원인을 설명하는 BaseReason 객체
     */
    protected MasterException(BaseReason reason) {
        super(reason.getMessage()); // 상위 RuntimeException에 메시지 설정
        this.reason = reason; // 예외 원인을 저장
        this.messagePrefix = null;
        this.messageSuffix = null;
        this.customMessage = null;
    }

    /**
     * 생성자: 예외의 원인(`reason`)을 기반으로 예외를 생성합니다.
     * 
     * @param reason 예외의 원인을 설명하는 BaseReason 객체
     */
    protected MasterException(BaseReason reason, String customMessage) {
        super(customMessage); // 상위 RuntimeException에 메시지 설정
        this.reason = reason; // 예외 원인을 저장
        this.messagePrefix = null;
        this.messageSuffix = null;
        this.customMessage = customMessage;
    }

    /**
     * 생성자: 예외의 원인(`reason`)을 기반으로 예외를 생성합니다.
     * 
     * @param reason 예외의 원인을 설명하는 BaseReason 객체
     */
    protected MasterException(BaseReason reason, String messagePrefix, String messageSuffix) {
        super((StringUtils.isNotNullEmpty(messagePrefix) ? messagePrefix : "") + reason.getMessage() + (StringUtils.isNotNullEmpty(messageSuffix) ? messageSuffix : "")); // 상위 RuntimeException에 메시지 설정
        this.reason = reason; // 예외 원인을 저장
        this.customMessage = null;
        this.messagePrefix = messagePrefix;
        this.messageSuffix = messageSuffix;
    }

    /**
     * 예외의 코드 값을 반환합니다.
     * 
     * @return 예외의 코드 (Integer 타입)
     */
    public Integer getReasonCode() {
        return reason.getCode();
    }

    /**
     * 예외의 메시지를 반환합니다.
     * 
     * @return 예외의 메시지 (String 타입)
     */
    public String getReasonMessage() {
        return reason.getMessage();
    }
}
