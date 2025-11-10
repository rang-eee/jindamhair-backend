package com.jindam.util.validators;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.stereotype.Component;

/**
 * DTO 객체를 Map<String, Object> 형태로 변환하는 유틸리티 클래스
 */
@Component
public class DtoUtils {

    /**
     * DTO 객체를 Map<String, Object>로 변환하는 메소드
     *
     * @param dto 변환할 DTO 객체
     * @return DTO의 필드명을 키(key), 필드 값을 값(value)으로 하는 Map 객체
     */
    public static Map<String, Object> convertDtoToMap(Object dto) {
        Map<String, Object> map = new HashMap<>();
        try {
            Class<?> currentClass = dto.getClass();

            // 상속받은 필드까지 가져오기 위해 상위 클래스로 순회
            while (currentClass != null) {
                for (Field field : currentClass.getDeclaredFields()) {
                    field.setAccessible(true); // private 필드 접근 가능하도록 설정
                    Object value = field.get(dto); // 필드 값 가져오기

                    // 필드 값이 null이 아닌 경우에만 Map에 추가
                    if (value != null) {
                        // Enum 타입이면 String으로 변환하여 저장
                        if (value instanceof Enum) {
                            map.put(field.getName(), ((Enum<?>) value).name());
                        } else {
                            map.put(field.getName(), value);
                        }
                    }
                }
                // 부모 클래스로 이동
                currentClass = currentClass.getSuperclass();
            }
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        }
        return map;
    }

    // DTO 객체에서 중복 없이 필드명만 가져오는 메서드
    public static List<String> getFieldNames(Object dto) {
        Set<String> fieldNames = new LinkedHashSet<>(); // 중복 제거 + 순서 유지
        Class<?> currentClass = dto.getClass();

        // 부모 클래스를 포함하여 모든 필드 가져오기
        while (currentClass != null) {
            for (Field field : currentClass.getDeclaredFields()) {
                fieldNames.add(field.getName()); // 필드명 추가 (중복 자동 제거)
            }
            currentClass = currentClass.getSuperclass(); // 부모 클래스로 이동
        }

        return new ArrayList<>(fieldNames); // Set을 List로 변환하여 반환
    }

}
