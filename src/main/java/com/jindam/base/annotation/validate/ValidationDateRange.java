package com.jindam.base.annotation.validate;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import com.jindam.util.validators.ValidatorDateRange;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

/**
 * 시작일과 종료일의 유효성을 검사하는 어노테이션입니다. <br/>
 * 단일 쌍 또는 다중 쌍의 시작일과 종료일을 비교하여 유효성을 검증합니다. <br/>
 * 종료일이 시작일보다 이전일 경우 유효성 검사에 실패합니다. <br/>
 * 
 * {@link ValidatorDateRange} 클래스를 통해 검증 로직이 수행됩니다.
 */
@Constraint(validatedBy = ValidatorDateRange.class) // 검증 로직을 처리하는 Validator 클래스 지정
@Target({ ElementType.TYPE }) // 어노테이션 적용 위치: 클래스 또는 객체 레벨
@Retention(RetentionPolicy.RUNTIME) // 런타임 시 어노테이션 정보 유지
public @interface ValidationDateRange {

    /**
     * 단일 시작일과 종료일 필드를 지정합니다. <br/>
     * 해당 필드만 유효성 검사가 적용됩니다.
     *
     * @return 시작일 필드명
     */
    String startField() default "";

    /**
     * 종료일 필드를 지정합니다.
     *
     * @return 종료일 필드명
     */
    String endField() default "";

    /**
     * 다중 필드 쌍을 지정합니다. <br/>
     * 필드 쌍은 콤마(,)로 구분됩니다. 예: {"start1,end1", "start2,end2"}
     *
     * @return 시작일과 종료일 필드 쌍 목록
     */
    String[] fields() default {};

    /////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////

    /**
     * 에러 메시지를 설정합니다. 기본 메시지 키는 {validation.date.range.invalid}입니다.
     *
     * @return 에러 메시지
     */
    String message() default "{validation.date.range.invalid}";

    /**
     * 유효성 검증 그룹을 지정합니다.
     * 
     * @return 검증 그룹
     */
    Class<?>[] groups() default {};

    /**
     * 유효성 검증에 대한 추가 메타데이터를 지정합니다.
     * 
     * @return Payload 정보
     */
    Class<? extends Payload>[] payload() default {};
}
