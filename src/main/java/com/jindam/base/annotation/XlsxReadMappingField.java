package com.jindam.base.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 엑셀 조회 시 매핑될 컬럼을 정의하는 애너테이션
 * <p>
 * 이 애너테이션은 DTO의 필드를 엑셀의 헤더와 매핑하는 데 사용됩니다.
 */
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
public @interface XlsxReadMappingField {
    /**
     * 엑셀 헤더에 해당하는 컬럼 명칭
     * 
     * @return 컬럼의 이름
     */
    String column() default "";
}
