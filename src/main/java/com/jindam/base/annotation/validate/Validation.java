package com.jindam.base.annotation.validate;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import com.jindam.util.validators.Validator;
import com.jindam.util.validators.Validator.Format;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

/**
 * Validation 어노테이션
 * 
 * 확장된 유효성 검사 옵션을 제공하는 필드 및 파라미터를 검증하기 위한 커스텀 어노테이션입니다. <br/>
 * {@link Validator}와 통합되어 검증 로직을 처리합니다.
 */
@Documented
@Constraint(validatedBy = Validator.class) // 검증 로직을 처리하는 Validator 클래스 지정
@Target({ ElementType.FIELD, ElementType.PARAMETER }) // 어노테이션 적용 위치: 필드 및 메서드 파라미터
@Retention(RetentionPolicy.RUNTIME) // 런타임 시 어노테이션 정보 유지
public @interface Validation {

    /**
     * 검증할 필드 이름을 지정합니다. <br/>
     * 에러 메시지를 생성할 때 사용됩니다.
     * 
     * @return 필드 이름
     */
    String field();

    /**
     * 기본 에러 메시지를 설정합니다. <br/>
     * 유효성 검사 문제에 대한 일반적인 에러 메시지를 제공합니다.
     * 
     * @return 기본 에러 메시지
     */
    String baseMsg() default "";

    /**
     * 필드가 비어 있으면 안 되는지 여부를 지정합니다.
     * 
     * @return true이면 필드가 비어 있으면 안 됩니다.
     */
    boolean notEmpty() default true;

    /**
     * "notEmpty" 검증 규칙에 대한 사용자 정의 에러 메시지를 설정합니다.
     * 
     * @return 비어 있으면 안 되는 경우의 에러 메시지
     */
    String notEmptyMsg() default "";

    /**
     * 필드가 특정 크기와 정확히 일치해야 하는지 지정합니다. <br/>
     * -1로 설정하면 이 규칙은 무시됩니다.
     * 
     * @return 필드가 만족해야 하는 정확한 크기
     */
    int size() default -1;

    /**
     * "size" 검증 규칙에 대한 사용자 정의 에러 메시지를 설정합니다.
     * 
     * @return 정확한 크기를 만족하지 못할 경우의 에러 메시지
     */
    String sizeMsg() default "";

    /**
     * 필드가 만족해야 하는 최소 크기를 지정합니다. <br/>
     * -1로 설정하면 이 규칙은 무시됩니다.
     * 
     * @return 필드의 최소 크기
     */
    int minSize() default -1;

    /**
     * "minSize" 검증 규칙에 대한 사용자 정의 에러 메시지를 설정합니다.
     * 
     * @return 최소 크기를 만족하지 못할 경우의 에러 메시지
     */
    String minSizeMsg() default "";

    /**
     * 필드가 만족해야 하는 최대 크기를 지정합니다. <br/>
     * -1로 설정하면 이 규칙은 무시됩니다.
     * 
     * @return 필드의 최대 크기
     */
    int maxSize() default -1;

    /**
     * "maxSize" 검증 규칙에 대한 사용자 정의 에러 메시지를 설정합니다.
     * 
     * @return 최대 크기를 초과할 경우의 에러 메시지
     */
    String maxSizeMsg() default "";

    /**
     * 필드가 따라야 하는 형식을 지정합니다. <br/>
     * 지원되는 형식은 {@link Format}에 정의되어 있습니다.
     * 
     * @return 필드가 만족해야 하는 형식
     */
    Format format() default Format.NONE;

    /**
     * 필드가 따라야 하는 형식 검증에 실패했을 경우의 사용자 정의 에러 메시지를 설정합니다.
     * 
     * @return 필드가 따라야 하는 형식 검증 실패 시의 에러 메시지
     */
    String formatMsg() default "";

    /**
     * 특정 정규식 패턴을 필드가 만족해야 하는지 지정합니다. <br/>
     * 빈 문자열로 남겨두면 이 규칙은 무시됩니다.
     * 
     * @return 검증을 위한 정규식 패턴
     */
    String pattern() default "";

    /**
     * 정규식 패턴 검증에 실패했을 경우의 사용자 정의 에러 메시지를 설정합니다.
     * 
     * @return 정규식 패턴 검증 실패 시의 에러 메시지
     */
    String patternMsg() default "";

    /////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////

    /**
     * 유효성 검증의 기본 에러 메시지입니다.
     * 
     * @return 기본 에러 메시지
     */
    String message() default "유효하지 않은 값입니다.";

    /**
     * 유효성 검증 그룹을 지정합니다.
     * 
     * @return 유효성 검증 그룹
     */
    Class<?>[] groups() default {};

    /**
     * 유효성 검증에 대한 추가 메타데이터를 지정합니다.
     * 
     * @return 유효성 검증에 대한 Payload 정보
     */
    Class<? extends Payload>[] payload() default {};
}
