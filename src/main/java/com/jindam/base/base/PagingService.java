package com.jindam.base.base;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.binding.BindingException;
import org.mybatis.spring.MyBatisSystemException;
import org.springframework.jdbc.BadSqlGrammarException;

import com.ourhome.tqms.common.dto.PagingRequestBaseDto;
import com.ourhome.tqms.common.dto.PagingResponseDto;
import com.ourhome.tqms.libs.Utils;

import lombok.extern.slf4j.Slf4j;

/**
 * 공통 페이징 처리 서비스 클래스.
 * 
 * 컨트롤러에서 사용되는 페이징 응답 처리를 위한 공통 메서드를 제공합니다. <br/>
 * 이 클래스는 요청 객체를 기반으로 매퍼의 메서드를 호출하여 페이징 처리 결과를 {@link PagingResponseDto} 형태로 반환합니다.
 */
@Slf4j
public class PagingService {

    @SuppressWarnings("unchecked")
    public static <T, R extends PagingRequestBaseDto> PagingResponseDto<T> findData(Object mapper, String methodName, R request) {
        List<T> results = new ArrayList<T>();
        T resultSummary = null; // 요약 결과를 담기 위한 변수
        int totalCount = 0;

        int offset = request.getOffset();
        int page = request.getPage();
        int limit = request.getLimit();
        boolean useSummary = request.isUseSummary();

        String countMethodName = methodName + "Count";
        String summaryMethodName = methodName + "Summary";

        if (offset < 0) {
            return PagingResponseDto.<T>builder()
                .size(limit)
                .number(page)
                .totalPages((int) Math.ceil((double) totalCount / limit))
                .totalElements(totalCount)
                .content(results)
                .build();
        }

        // Count 쿼리 실행
        try {
            Method countMethod = mapper.getClass()
                .getMethod(countMethodName, request.getClass());
            totalCount = (Integer) countMethod.invoke(mapper, request);
        } catch (NoSuchMethodException e) {
            throw new RuntimeException("Count 쿼리: Mapper 인터페이스에 메서드가 존재하지 않습니다. Name : [" + countMethodName + "]", e);
        } catch (InvocationTargetException e) {
            Throwable cause = e.getCause();
            if (cause instanceof BadSqlGrammarException) {
                throw new RuntimeException("Count 쿼리 실행 중 PostgreSQL 실행 오류가 발생했습니다. 메서드: Name : [" + countMethodName + "]", cause);
            } else if (cause instanceof BindingException) {
                throw new RuntimeException("Count 쿼리: Mapper.xml에 매핑된 statement를 찾을 수 없습니다. 메서드: Name : [" + countMethodName + "]", cause);
            } else {
                throw new RuntimeException("Count 쿼리 실행 중 알 수 없는 오류가 발생했습니다. 메서드: Name : [" + countMethodName + "]", cause);
            }
        } catch (MyBatisSystemException e) {
            throw new RuntimeException("Count 쿼리 실행 중 MyBatis 시스템 오류가 발생했습니다.", e);
        } catch (Exception e) {
            throw new RuntimeException("Count 쿼리 실행 중 오류가 발생했습니다.", e);
        }

        // Data 쿼리 실행
        try {
            Method dataMethod = mapper.getClass()
                .getMethod(methodName, request.getClass());
            results = (List<T>) dataMethod.invoke(mapper, request);
        } catch (NoSuchMethodException e) {
            throw new RuntimeException("Data 쿼리: Mapper 인터페이스에 메서드가 존재하지 않습니다. Name : [" + methodName + "]", e);
        } catch (InvocationTargetException e) {
            Throwable cause = e.getCause();
            if (cause instanceof BadSqlGrammarException) {
                throw new RuntimeException("Data 쿼리 실행 중 PostgreSQL 실행 오류가 발생했습니다. 메서드: Name : [" + methodName + "]", cause);
            } else if (cause instanceof BindingException) {
                throw new RuntimeException("Data 쿼리: Mapper.xml에 매핑된 statement를 찾을 수 없습니다. 메서드: Name : [" + methodName + "]", cause);
            } else {
                throw new RuntimeException("Data 쿼리 실행 중 알 수 없는 오류가 발생했습니다. 메서드: Name : [" + methodName + "]", cause);
            }
        } catch (MyBatisSystemException e) {
            throw new RuntimeException("Data 쿼리 실행 중 MyBatis 시스템 오류가 발생했습니다.", e);
        } catch (Exception e) {
            throw new RuntimeException("Data 쿼리 실행 중 오류가 발생했습니다.", e);
        }

        // 동적 Map 결과 카멜케이스 키로 변환
        if (results != null && !results.isEmpty() && results.get(0) instanceof Map) {
            List<Map<String, Object>> mapList = (List<Map<String, Object>>) (List<?>) results;
            List<Map<String, Object>> camelList = Utils.toCamelCase(mapList);
            results = (List<T>) (List<?>) camelList;
        }

        // 페이지 번호, 페이지 크기 및 순번 계산
        Integer startNumber = totalCount - (page * limit);
        for (T dto : results) {
            // Map<String,Object> 분기 처리
            if (dto instanceof Map<?, ?>) {
                Map<String, Object> map = (Map<String, Object>) dto;
                map.put("number", startNumber--);
                continue;
            }

            boolean hasNumberField = false;
            for (Field field : dto.getClass()
                .getDeclaredFields()) {
                if ("number".equals(field.getName())) {
                    hasNumberField = true;
                    break;
                }
            }
            if (!hasNumberField) {
                continue;
            }
            try {
                Field numberField = dto.getClass()
                    .getDeclaredField("number");
                numberField.setAccessible(true);
                numberField.set(dto, startNumber--);
            } catch (NoSuchFieldException | IllegalAccessException e) {
                throw new RuntimeException("number 필드 접근 중 오류 발생", e);
            }
        }

        // 합계 쿼리 실행
        if (useSummary && page == 0) {
            try {
                request.setSearchAll(true);
                Method summaryMethod = mapper.getClass()
                    .getMethod(summaryMethodName, request.getClass());
                Object summaryObj = summaryMethod.invoke(mapper, request);

                // summary가 Map이면 camelCase 적용
                if (summaryObj instanceof Map) {
                    Map<String, Object> camelMap = Utils.toCamelCase((Map<String, Object>) summaryObj);
                    resultSummary = (T) camelMap;
                } else {
                    resultSummary = (T) summaryObj;
                }
            } catch (NoSuchMethodException e) {
                throw new RuntimeException("Data 쿼리: Mapper 인터페이스에 메서드가 존재하지 않습니다. Name : [" + summaryMethodName + "]", e);
            } catch (InvocationTargetException e) {
                Throwable cause = e.getCause();
                if (cause instanceof BadSqlGrammarException) {
                    throw new RuntimeException("Data 쿼리 실행 중 PostgreSQL 실행 오류가 발생했습니다. 메서드: Name : [" + summaryMethodName + "]", cause);
                } else if (cause instanceof BindingException) {
                    throw new RuntimeException("Data 쿼리: Mapper.xml에 매핑된 statement를 찾을 수 없습니다. 메서드: Name : [" + summaryMethodName + "]", cause);
                } else {
                    throw new RuntimeException("Data 쿼리 실행 중 알 수 없는 오류가 발생했습니다. 메서드: Name : [" + summaryMethodName + "]", cause);
                }
            } catch (MyBatisSystemException e) {
                throw new RuntimeException("Data 쿼리 실행 중 MyBatis 시스템 오류가 발생했습니다.", e);
            } catch (Exception e) {
                throw new RuntimeException("Data 쿼리 실행 중 오류가 발생했습니다.", e);
            }
        }

        // PagingResponseDto 생성 및 반환
        return PagingResponseDto.<T>builder()
            .size(limit)
            .number(page)
            .totalPages((int) Math.ceil((double) totalCount / limit))
            .totalElements(totalCount)
            .content(results)
            .summary(resultSummary)
            .build();
    }
}
