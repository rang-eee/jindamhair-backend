package com.jindam.base.base;

/**
 * 예외 또는 결과 코드의 원인(Reason)을 정의하기 위한 인터페이스
 * 
 * 각 예외 또는 API 응답에서 특정 코드와 메시지를 제공하기 위해 구현됩니다.
 */
public interface BaseReason {

    /**
     * 결과 또는 예외의 코드 값을 반환합니다.
     *
     * @return 코드 값 (Integer 타입)
     */
    Integer getCode();

    /**
     * 결과 또는 예외의 메시지를 반환합니다.
     *
     * @return 메시지 (String 타입)
     */
    String getMessage();
}
