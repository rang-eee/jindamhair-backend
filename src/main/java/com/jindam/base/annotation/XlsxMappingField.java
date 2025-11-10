package com.jindam.base.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * xlsx 생성시 매핑 될 컬럼 정의
 */
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface XlsxMappingField {
    /**
     * 컬럼 명칭
     * 
     * @return
     */
    String column() default "";

    /**
     * 컬럼 순서 (0부터 시작)
     * 
     * @return
     */
    @Deprecated
    int index() default 0;

    /**
     * 엑셀에서 이 컬럼을 숨길지 여부 (기본 false)
     */
    boolean hidden() default false;

    /**
     * 엑셀에 이 컬럼을 포함할지 여부 (기본 false) <br/>
     * true 이면 헤더 생성 단계에서 아예 skip 됩니다.
     */
    boolean use() default true;

    /**
     * 비활성화된 컬럼은 연한 회색 배경으로 표시합니다.
     */
    boolean disable() default false;
}
