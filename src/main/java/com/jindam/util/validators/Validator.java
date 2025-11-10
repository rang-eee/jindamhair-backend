package com.jindam.util.validators;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.regex.Pattern;

import com.jindam.base.annotation.validate.Validation;
import com.jindam.base.message.Message;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * Validator
 * 
 * 유효성 검사를 수행하는 클래스입니다. {@link Validation} 어노테이션과 통합되어 사용됩니다. <br/>
 * 필드 값의 조건을 검사하며, 조건에 따라 메시지를 설정합니다.
 */
public class Validator implements ConstraintValidator<Validation, Object> {

    private String field; // 검증할 필드 이름
    private String baseMsg; // 기본 메시지
    private boolean notEmpty; // NotEmpty 조건 여부
    private String notEmptyMsg; // NotEmpty 실패 시 메시지
    private int size; // 특정 크기 조건
    private String sizeMsg; // 크기 조건 실패 시 메시지
    private int minSize; // 최소 크기 조건
    private String minSizeMsg; // 최소 크기 실패 시 메시지
    private int maxSize; // 최대 크기 조건
    private String maxSizeMsg; // 최대 크기 실패 시 메시지
    private Format format; // 형식 조건
    private String formatMsg; // 형식 조건 실패 시 메시지
    private String pattern; // 정규식 조건
    private String patternMsg; // 정규식 조건 실패 시 메시지

    /**
     * ApiValidation 어노테이션 초기화 메서드. <br/>
     * 어노테이션에서 설정된 값을 가져옵니다.
     */
    @Override
    public void initialize(Validation annotation) {
        this.field = annotation.field();
        this.baseMsg = annotation.baseMsg();
        this.notEmpty = annotation.notEmpty();
        this.notEmptyMsg = annotation.notEmptyMsg();
        this.size = annotation.size();
        this.sizeMsg = annotation.sizeMsg();
        this.minSize = annotation.minSize();
        this.minSizeMsg = annotation.minSizeMsg();
        this.maxSize = annotation.maxSize();
        this.maxSizeMsg = annotation.maxSizeMsg();
        this.pattern = annotation.pattern();
        this.patternMsg = annotation.patternMsg();
        this.format = annotation.format();
        this.formatMsg = annotation.formatMsg();
    }

    /**
     * 실제 유효성 검사 로직을 구현한 메서드. <br/>
     * 주어진 값에 대해 설정된 조건들을 검사합니다.
     */
    @Override
    public boolean isValid(Object fieldValue, ConstraintValidatorContext context) {

        // notEmpty 검증
        // 값이 null이거나 비어 있거나, 공백만으로 이루어진 경우 검증 실패 처리
        if (notEmpty) {
            if (fieldValue == null || (fieldValue instanceof String && ((String) fieldValue).trim()
                .isEmpty())) {
                // 사용자 정의 메시지 설정
                setCustomMessage(context, resolveMessage(notEmptyMsg, // 조건별 사용자 정의 메시지
                        baseMsg, // 기본 메시지
                        getMessage("{validation.empty}", field) // 메시지 키를 통해 가져온 기본 메시지
                ));
                return false; // 검증 실패
            }
        }

        // 타입별 검증
        if (fieldValue instanceof String) {
            String value = (String) fieldValue;

            // notEmpty 검증
            // 값이 null이거나 비어 있거나, 공백만으로 이루어진 경우 검증 실패 처리
            if (value == null || value.isEmpty() || value.trim()
                .isEmpty()) {
                if (notEmpty) {
                    // 사용자 정의 메시지 설정
                    setCustomMessage(context, resolveMessage(notEmptyMsg, // 조건별 사용자 정의 메시지
                            baseMsg, // 기본 메시지
                            getMessage("{validation.empty}", field) // 메시지 키를 통해 가져온 기본 메시지
                    ));
                    return false; // 검증 실패
                }

                // 빈 값 허용 시 바로 통과
                return true;
            }

            // size 검증
            // 특정 크기(size)와 정확히 일치하지 않을 경우 검증 실패 처리
            if (size > -1 && value.length() != size) {
                // 메시지에 필드 이름과 크기 전달
                setCustomMessage(context, resolveMessage(sizeMsg, baseMsg, getMessage("{validation.size.exact}", field, size)));
                return false; // 검증 실패
            }

            // minSize 검증
            // 최소 크기(minSize)를 만족하지 않을 경우 검증 실패 처리
            if (minSize > -1 && value.length() < minSize) {
                // 메시지에 필드 이름과 최소 크기 전달
                setCustomMessage(context, resolveMessage(minSizeMsg, baseMsg, getMessage("{validation.size.min}", field, minSize)));
                return false; // 검증 실패
            }

            // maxSize 검증
            // 최대 크기(maxSize)를 초과할 경우 검증 실패 처리
            if (maxSize > -1 && value.length() > maxSize) {
                // 메시지에 필드 이름과 최대 크기 전달
                setCustomMessage(context, resolveMessage(maxSizeMsg, baseMsg, getMessage("{validation.size.max}", field, maxSize)));
                return false; // 검증 실패
            }

            // format 검증
            // 특정 형식(format)에 부합하지 않을 경우 검증 실패 처리
            if (!Format.NONE.equals(format)) {
                if (!Pattern.matches(format.getRegex(), value)) {
                    // 메시지 키를 통해 포맷 오류 메시지 가져오기
                    setCustomMessage(context, resolveMessage(formatMsg, baseMsg, getMessage(format.getMessageKey(), field)));
                    return false; // 검증 실패
                }
            }

            // pattern 검증
            // 사용자 정의 패턴(pattern)에 부합하지 않을 경우 검증 실패 처리
            if (!pattern.isEmpty() && !Pattern.matches(pattern, value)) {
                // 기본 패턴 검증 실패 메시지
                setCustomMessage(context, resolveMessage(patternMsg, baseMsg, getMessage("{validation.pattern.invalid}", field)));
                return false; // 검증 실패
            }

            // 모든 검증을 통과한 경우 true 반환
            return true;

        } else if (fieldValue instanceof LocalDate) {
            LocalDate value = (LocalDate) fieldValue;

            // LocalDate 포맷인지 검증
            if (!Format.DATE.equals(format) && !Format.DATE_YY.equals(format)) {
                setCustomMessage(context, resolveMessage(formatMsg, baseMsg, getMessage("{validation.pattern.date.localdate}", field)));
                return false;
            }

            // 포맷에 부합하는지 검증
            String dateValue = value.toString(); // LocalDate의 문자열 표현
            if (!Pattern.matches(format.getRegex(), dateValue)) {
                setCustomMessage(context, resolveMessage(formatMsg, baseMsg, getMessage(format.getMessageKey(), field)));
                return false;
            }

            return true;
        } else if (fieldValue instanceof LocalDateTime) {
            LocalDateTime value = (LocalDateTime) fieldValue;

            // LocalDateTime 포맷인지 검증
            if (!Format.DATETIME.equals(format) && !Format.DATETIME_YY.equals(format)) {
                setCustomMessage(context, resolveMessage(formatMsg, baseMsg, getMessage("{validation.pattern.date.localdatetime}", field)));
                return false;
            }

            // 포맷에 부합하는지 검증
            String dateValue = value.toString()
                .replace("T", " ");
            if (!Pattern.matches(format.getRegex(), dateValue)) {
                setCustomMessage(context, resolveMessage(formatMsg, baseMsg, getMessage(format.getMessageKey(), field)));
                return false;
            }

            return true;
        } else {
            return true;
        }
    }

    /**
     * 사용자 정의 메시지를 설정합니다.
     * 
     * @param context ConstraintValidatorContext
     * @param message 사용자 정의 메시지
     */
    private void setCustomMessage(ConstraintValidatorContext context, String message) {
        context.disableDefaultConstraintViolation();
        context.buildConstraintViolationWithTemplate(message)
            .addConstraintViolation();
    }

    /**
     * 메시지를 우선순위에 따라 결정합니다. <br/>
     * 1. specificMsg (개별 조건 메시지) <br/>
     * 2. baseMsg (기본 메시지) <br/>
     * 3. defaultMsg (기본 값 메시지)
     * 
     * @param specificMsg 개별 조건 메시지
     * @param baseMsg 기본 메시지
     * @param defaultMsg 기본 값 메시지
     * @return 최종 메시지
     */
    private String resolveMessage(String specificMsg, String baseMsg, String defaultMsg) {
        String resolvedBaseMsg = isMessageKey(baseMsg) ? getMessage(baseMsg, field) : baseMsg;
        if (specificMsg != null && !specificMsg.isEmpty()) {
            return specificMsg;
        } else if (resolvedBaseMsg != null && !resolvedBaseMsg.isEmpty()) {
            return resolvedBaseMsg;
        } else {
            return defaultMsg;
        }
    }

    /**
     * 메시지가 키 형식인지 확인합니다.
     * 
     * @param message 메시지
     * @return 키 형식 여부
     */
    private boolean isMessageKey(String message) {
        return message != null && message.startsWith("{") && message.endsWith("}");
    }

    /**
     * 메시지 키를 기반으로 메시지를 가져옵니다. <br/>
     * 키 형식이 아닌 경우 메시지 자체를 반환합니다.
     * 
     * @param key 메시지 키
     * @param args 메시지의 포맷 인자
     * @return 최종 메시지
     */
    private String getMessage(String key, Object... args) {
        if (isMessageKey(key)) {
            String actualKey = key.substring(1, key.length() - 1); // Remove { and }
            return Message.getMessage(actualKey, args);
        }
        return key; // Directly return if it's not a key
    }

    /**
     * 유효성 검사에 사용되는 형식(enum) 정의.
     * 
     * 각 항목은 정규식과 해당 항목의 메시지 키를 포함합니다.<br/>
     * 정규식은 필드 값의 유효성을 검사하는 데 사용되며, 메시지 키는 에러 메시지 출력 시 참조됩니다.
     */
    @Getter
    @AllArgsConstructor
    public enum Format {
        NONE("", ""), // 검증을 수행하지 않는 기본 형식

        // 여부 관련
        BOOL("^(true|false)$", "{validation.pattern.bool}"), // true 또는 false 허용
        YN("^Y|N$", "{validation.pattern.yn}"), // Y 또는 N 허용

        // 공백 불가능
        TEXT("^[A-Za-z가-힣]+$", "{validation.pattern.text}"), // 영문 및 한글만 허용 (공백 불가능)
        TEXT_NUMERIC("^[A-Za-z가-힣\\d]+$", "{validation.pattern.text_numeric}"), // 영문, 한글, 숫자만 허용 (공백 불가능)
        TEXT_NUMERIC_SPECIAL("^[A-Za-z가-힣\\d!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.text_numeric_special}"), // 영문, 한글, 숫자, 특수문자만 허용 (공백 불가능)
        TEXT_SPECIAL("^[A-Za-z가-힣!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.text_special}"), // 영문, 한글, 특수문자만 허용 (공백 불가능)

        // 공백 가능
        TEXT_SPACE("^[A-Za-z가-힣\\s]+$", "{validation.pattern.text_space}"), // 영문 및 한글, 공백 허용
        TEXT_NUMERIC_SPACE("^[A-Za-z가-힣\\d\\s]+$", "{validation.pattern.text_numeric_space}"), // 영문, 한글, 숫자, 공백 허용
        TEXT_NUMERIC_SPECIAL_SPACE("^[A-Za-z가-힣\\d\\s!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.text_numeric_special_space}"), // 영문, 한글, 숫자, 특수문자, 공백 허용
        TEXT_SPECIAL_SPACE("^[A-Za-z가-힣\\s!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.text_special_space}"), // 영문, 한글, 특수문자, 공백 허용

        // 숫자 관련
        NUMERIC("^\\d+$", "{validation.pattern.numeric}"), // 숫자만 허용 (공백 불가능)
        NUMERIC_DECIMAL("^\\d+(\\.\\d+)?$", "{validation.pattern.decimal}"), // 숫자와 . 허용
        NUMERIC_SPECIAL("^[\\d!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.numeric_special}"), // 숫자와 특수문자만 허용 (공백 불가능)
        NUMERIC_SPACE("^\\d\\s+$", "{validation.pattern.numeric_space}"), // 숫자와 공백만 허용
        NUMERIC_SPECIAL_SPACE("^[\\d\\s!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.numeric_special_space}"), // 숫자, 특수문자, 공백 허용

        // 영문 관련
        ENGLISH("^[A-Za-z]+$", "{validation.pattern.english}"), // 영문(대소문자)만 허용 (공백 불가능)
        ENGLISH_SLASH("^[A-Za-z/]+$", "{validation.pattern.english}"), // 영문(대소문자)와 슬래시만 허용 (공백 불가능)
        ENGLISH_NUMERIC("^[A-Za-z\\d]+$", "{validation.pattern.english_numeric}"), // 영문(대소문자)와 숫자만 허용 (공백 불가능)
        ENGLISH_NUMERIC_SPECIAL("^[A-Za-z\\d!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.english_numeric_special}"), // 영문, 숫자, 특수문자만 허용 (공백 불가능)
        ENGLISH_SPACE("^[A-Za-z\\s]+$", "{validation.pattern.english_space}"), // 영문(대소문자)과 공백만 허용
        ENGLISH_NUMERIC_SPACE("^[A-Za-z\\d\\s]+$", "{validation.pattern.english_numeric_space}"), // 영문, 숫자, 공백 허용
        ENGLISH_NUMERIC_SPECIAL_SPACE("^[A-Za-z\\d\\s!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.english_numeric_special_space}"), // 영문, 숫자, 특수문자, 공백 허용

        // 한글 관련
        KOREAN("^[가-힣]+$", "{validation.pattern.korean}"), // 한글만 허용 (공백 불가능)
        KOREAN_NUMERIC("^[가-힣\\d]+$", "{validation.pattern.korean_numeric}"), // 한글과 숫자만 허용 (공백 불가능)
        KOREAN_NUMERIC_SPECIAL("^[가-힣\\d!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.korean_numeric_special}"), // 한글, 숫자, 특수문자만 허용 (공백 불가능)
        KOREAN_SPACE("^[가-힣\\s]+$", "{validation.pattern.korean_space}"), // 한글과 공백만 허용
        KOREAN_NUMERIC_SPACE("^[가-힣\\d\\s]+$", "{validation.pattern.korean_numeric_space}"), // 한글, 숫자, 공백 허용
        KOREAN_NUMERIC_SPECIAL_SPACE("^[가-힣\\d\\s!@#$%^&*(),.?\":{}|<>_\\-]+$", "{validation.pattern.korean_numeric_special_space}"), // 한글, 숫자, 특수문자, 공백 허용

        // 날짜 관련(구분자: -, ., / 허용)
        DATE("^\\d{4}[-./](\\d{2})[-./](\\d{2})$", "{validation.pattern.date_yyyy}"), // 연월일 yyyy-MM-dd 형식
        DATE_YY("^\\d{2}[-./](\\d{2})[-./](\\d{2})$", "{validation.pattern.date_yy}"), // 연월일 yy-MM-dd 형식
        DATETIME("^\\d{4}[-./](\\d{2})[-./](\\d{2})\\s(\\d{2}):(\\d{2}):(\\d{2})$", "{validation.pattern.datetime_yyyy}"), // 연월일 시분초 yyyy-MM-dd HH:mm:ss 형식
        DATETIME_YY("^\\d{2}[-./](\\d{2})[-./](\\d{2})\\s(\\d{2}):(\\d{2}):(\\d{2})$", "{validation.pattern.datetime_yy}"), // 연월일 시분초 yy-MM-dd HH:mm:ss 형식

        // 기타
        EMAIL("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$", "{validation.pattern.email}"), // 이메일 주소 형식만 허용하는 형식
        PHONE("^\\d{2,3}-\\d{3,4}-\\d{4}$", "{validation.pattern.phone}"), // 전화번호 형식만 허용하는 형식 (예: 010-1234-5678)
        PASSWORD("^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[@$!%*?&#_^()\\-])[A-Za-z\\d@$!%*?&#_^()\\-]{8,}$", "{validation.pattern.password}"), // 대문자, 소문자, 숫자, 특수문자를 모두 포함하는 비밀번호 형식
        BSNM_NUMBER("^[0-9]{3}-[0-9]{2}-[0-9]{5}$", "{validation.pattern.bsnm_number}"), // 사업자 번호(123-45-67890) 형식: 숫자 3개-숫자 2개-숫자 5개
        ;

        /** 정규식을 저장하는 필드 */
        private final String regex;

        /** 메시지 키를 저장하는 필드 */
        private final String messageKey;
    }

    /** 어노테이션 사용 이외의 필드에서 Validator 검증을 사용하기 위한 메소드 */
    public ValidationResult validateField(Object fieldValue) {
        ValidationResult result = new ValidationResult();

        // 기본값 설정
        result.setValid(true); // 초기값: 유효함
        result.setMessage(""); // 초기값: 메시지 없음

        // notEmpty 검증
        if (notEmpty) {
            if (fieldValue == null || (fieldValue instanceof String && ((String) fieldValue).trim()
                .isEmpty())) {
                result.setValid(false);
                result.setMessage(resolveMessage(notEmptyMsg, baseMsg, getMessage("{validation.empty}", field)));
                return result;
            }
        }

        // 타입별 검증
        if (fieldValue instanceof String) {
            String value = (String) fieldValue;

            // size 검증
            if (size > -1 && value.length() != size) {
                result.setValid(false);
                result.setMessage(resolveMessage(sizeMsg, baseMsg, getMessage("{validation.size.exact}", field, size)));
                return result;
            }

            // minSize 검증
            if (minSize > -1 && value.length() < minSize) {
                result.setValid(false);
                result.setMessage(resolveMessage(minSizeMsg, baseMsg, getMessage("{validation.size.min}", field, minSize)));
                return result;
            }

            // maxSize 검증
            if (maxSize > -1 && value.length() > maxSize) {
                result.setValid(false);
                result.setMessage(resolveMessage(maxSizeMsg, baseMsg, getMessage("{validation.size.max}", field, maxSize)));
                return result;
            }

            // format 검증
            if (!Format.NONE.equals(format) && !Pattern.matches(format.getRegex(), value)) {
                result.setValid(false);
                result.setMessage(resolveMessage(formatMsg, baseMsg, getMessage(format.getMessageKey(), field)));
                return result;
            }

            // pattern 검증
            if (!pattern.isEmpty() && !Pattern.matches(pattern, value)) {
                result.setValid(false);
                result.setMessage(resolveMessage(patternMsg, baseMsg, getMessage("{validation.pattern.invalid}", field)));
                return result;
            }
        }

        return result;
    }

    public void initialize(ValidationParameters params) {
        this.field = params.getField();
        this.format = params.getFormat();
        this.notEmpty = params.isNotEmpty();
        this.size = params.getSize();
        this.minSize = params.getMinSize();
        this.maxSize = params.getMaxSize();
        this.pattern = params.getPattern();
        this.notEmptyMsg = params.getMessage(params.getNotEmptyMsg(), field);
        this.sizeMsg = params.getMessage(params.getSizeMsg(), field, size);
        this.minSizeMsg = params.getMessage(params.getMinSizeMsg(), field, minSize);
        this.maxSizeMsg = params.getMessage(params.getMaxSizeMsg(), field, maxSize);
        this.formatMsg = params.getMessage(params.getFormatMsg(), field);
        this.patternMsg = params.getMessage(params.getPatternMsg(), field);
    }

    public interface ErrorResponse {
        void setIsErrorYn(String yn);

        void setStatus(String status);
    }

    /**
     * 필드 검증 메서드
     *
     * @param <T> Validator.ErrorResponse를 구현한 DTO 타입
     * @param value 검사할 값
     * @param params Validator 초기화 파라미터
     * @param response 결과 DTO (오류 정보를 담기 위해)
     * @return 검증 실패 시 true, 통과 시 false
     */
    public static <T extends Validator.ErrorResponse> boolean validateByParams(String value, ValidationParameters params, T response) {
        Validator validator = new Validator();
        params.setFormatMsg(params.getField() + " 입력 규칙에 맞지 않습니다");
        validator.initialize(params);

        ValidationResult result = validator.validateField(value);
        if (!result.isValid()) {
            response.setIsErrorYn("Y");
            response.setStatus(result.getMessage());
            return true;
        }
        return false;
    }

}
