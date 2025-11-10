package com.jindam.util.validators;

import java.lang.reflect.Field;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

import com.jindam.base.annotation.validate.ValidationDateRange;
import com.jindam.base.message.Message;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

/**
 * 시작일과 종료일의 유효성을 검사하는 Validator입니다. <br/>
 * {@link ValidationDateRange} 어노테이션을 사용해 지정된 필드 쌍을 검사합니다. <br/>
 * 종료일이 시작일보다 이전일 경우 검증에 실패합니다. <br/>
 * 
 * 
 * **사용 예시**:
 * 
 * // 1. 단일 필드 쌍 검사
 * 
 * <pre>
 * @ValidationDateRange(startField = "startAt", endField = "endAt")
 * public class ExampleRequest {
 *     private LocalDateTime startAt;
 *     private LocalDateTime endAt;
 *     // Getter, Setter 생략
 * }
 * </pre>
 * 
 * // 2. 다중 필드 쌍 검사
 * 
 * <pre>
 * @ValidationDateRange(fields = { "useStartAt useEndAt", "regStartAt regEndAt" })
 * public class MultiExampleRequest {
 *     private LocalDate useStartAt;
 *     private LocalDate useEndAt;
 *     private LocalDateTime regStartAt;
 *     private LocalDateTime regEndAt;
 *     // Getter, Setter 생략
 * }
 * </pre>
 * 
 * 위 예시에서: <br/>
 * - `startField`와 `endField`를 사용하면 단일 필드 쌍(하나의 시작일과 종료일)을 검사합니다. <br/>
 * - `fields` 속성을 사용하면 여러 필드 쌍을 동시에 검사할 수 있습니다. 쌍은 `" "`(공백)으로 구분됩니다. <br/>
 * 
 * 검증 실패 시 각 필드에 해당하는 에러 메시지가 출력됩니다.
 */

public class ValidatorDateRange implements ConstraintValidator<ValidationDateRange, Object> {

    private String startFieldName; // 단일 시작일 필드명
    private String endFieldName; // 단일 종료일 필드명
    private String[] fieldPairs; // 다중 필드 쌍 목록

    /**
     * 어노테이션의 속성 값을 초기화합니다.
     * 
     * @param constraintAnnotation 어노테이션 설정 값
     */
    @Override
    public void initialize(ValidationDateRange constraintAnnotation) {
        this.startFieldName = constraintAnnotation.startField();
        this.endFieldName = constraintAnnotation.endField();
        this.fieldPairs = constraintAnnotation.fields();
    }

    /**
     * 유효성 검사를 수행합니다.
     * 
     * @param targetObject 대상 객체 (유효성을 검사할 필드를 가진 객체)
     * @param context ConstraintValidatorContext (검증 오류 메시지 설정에 사용)
     * @return 유효하면 true, 아니면 false
     */
    @Override
    public boolean isValid(Object targetObject, ConstraintValidatorContext context) {
        List<String> fieldNames = new ArrayList<>();

        // 오류 메시지 출력을 위한 필드 이름 수집
        if (!startFieldName.isEmpty())
            fieldNames.add(startFieldName);
        if (!endFieldName.isEmpty())
            fieldNames.add(endFieldName);

        if (fieldPairs.length > 0) {
            for (String fieldPair : fieldPairs) {
                Stream.of(fieldPair.split(" "))
                    .forEach(fieldNames::add);
            }
        }

        try {
            // 단일 필드 쌍 유효성 검사
            if (!startFieldName.isEmpty() && !endFieldName.isEmpty()) {
                if (!validateDateRange(targetObject, startFieldName, endFieldName, context)) {
                    return false;
                }
            }

            // 다중 필드 쌍 유효성 검사
            for (String fieldPair : fieldPairs) {
                String[] fields = fieldPair.split(" ");
                if (fields.length == 2) {
                    if (!validateDateRange(targetObject, fields[0].trim(), fields[1].trim(), context)) {
                        return false;
                    }
                }
            }
        } catch (NoSuchFieldException e) {
            // 필드가 존재하지 않는 경우
            setCustomValidationMessage(context, getMessage("{validation.date.not.exist}", String.join("/", fieldNames)));
            return false;
        } catch (Exception e) {
            // 기타 예외 발생 시 오류 처리
            setCustomValidationMessage(context, getMessage("{validation.date.invalid}", String.join("/", fieldNames)));
            return false;
        }
        return true;
    }

    /**
     * 시작일과 종료일의 유효성을 검사합니다.
     * 
     * @param targetObject 대상 객체
     * @param startField 시작일 필드명
     * @param endField 종료일 필드명
     * @param context ConstraintValidatorContext
     * @return 유효하면 true, 아니면 false
     * @throws Exception Reflection 접근 중 예외 발생
     */
    private boolean validateDateRange(Object targetObject, String startField, String endField, ConstraintValidatorContext context) throws Exception {
        Class<?> targetRef = targetObject.getClass();

        // 대상 객체의 필드 참조 가져오기
        Field startFieldRef = targetRef.getDeclaredField(startField);
        Field endFieldRef = targetRef.getDeclaredField(endField);

        startFieldRef.setAccessible(true);
        endFieldRef.setAccessible(true);

        Object startValue = startFieldRef.get(targetObject);
        Object endValue = endFieldRef.get(targetObject);

        // 둘 다 null인 경우 검증 생략
        if (startValue == null && endValue == null) {
            return true;
        }

        // LocalDate 및 LocalDateTime 타입 확인
        if ((startValue instanceof LocalDate || startValue instanceof LocalDateTime) && (endValue instanceof LocalDate || endValue instanceof LocalDateTime)) {

            // 둘 중 하나만 null인 경우 오류 메시지 반환
            if (startValue == null || endValue == null) {
                String emptyField = startValue == null ? startField : endField;
                setCustomValidationMessage(context, getMessage("{validation.empty}", emptyField));
                return false;
            }

            // 날짜 값을 LocalDateTime으로 변환
            LocalDateTime startDateTime = convertToLocalDateTime(startValue);
            LocalDateTime endDateTime = convertToLocalDateTime(endValue);

            // 종료일이 시작일보다 이전인지 확인
            if (endDateTime.isBefore(startDateTime)) {
                setCustomValidationMessage(context, getMessage("{validation.date.range}", startField, endField));
                return false;
            }
        } else {
            // 필드 타입이 LocalDate 또는 LocalDateTime이 아닌 경우
            setCustomValidationMessage(context, getMessage("{validation.date.invalid}", startField, endField));
            return false;
        }

        return true;
    }

    /**
     * LocalDate 또는 LocalDateTime을 LocalDateTime으로 변환합니다.
     * 
     * @param date 변환할 객체 (LocalDate 또는 LocalDateTime)
     * @return LocalDateTime 형식으로 변환된 값
     */
    private LocalDateTime convertToLocalDateTime(Object date) {
        if (date instanceof LocalDateTime) {
            return (LocalDateTime) date;
        } else if (date instanceof LocalDate) {
            return ((LocalDate) date).atStartOfDay();
        }
        return null;
    }

    /**
     * 사용자 정의 검증 메시지를 설정합니다.
     * 
     * @param context ConstraintValidatorContext
     * @param message 사용자 정의 메시지
     */
    private void setCustomValidationMessage(ConstraintValidatorContext context, String message) {
        context.disableDefaultConstraintViolation();
        context.buildConstraintViolationWithTemplate(message)
            .addConstraintViolation();
    }

    /**
     * 메시지 키를 기반으로 메시지를 가져옵니다.
     * 
     * @param messageKey 메시지 키
     * @param args 메시지에 전달할 인자 값
     * @return 메시지 키에 해당하는 메시지 문자열
     */
    private String getMessage(String messageKey, Object... args) {
        if (isMessageKey(messageKey)) {
            String actualKey = messageKey.substring(1, messageKey.length() - 1); // { } 제거
            return Message.getMessage(actualKey, args);
        }
        return messageKey; // 키가 아니면 원래 메시지 반환
    }

    /**
     * 메시지가 키 형식인지 확인합니다.
     * 
     * @param message 메시지 문자열
     * @return 키 형식이면 true, 아니면 false
     */
    private boolean isMessageKey(String message) {
        return message != null && message.startsWith("{") && message.endsWith("}");
    }
}
