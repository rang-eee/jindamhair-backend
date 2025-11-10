package com.jindam.util.validators;

import com.jindam.base.enums.CodeEnum;

public class EnumUtils {
    /**
     * name으로 enum을 조회하는 공통 메서드
     * 
     * @param enumClass enum 클래스 타입
     * @param name 조회할 name 값
     * @param <E> Enum 타입 (CodeEnum을 구현한)
     * @return 일치하는 enum, 없으면 null
     */
    public static <E extends Enum<E>> E convert(String name, Class<E> enumClass) {
        if (name == null) {
            return null;
        }
        for (E constant : enumClass.getEnumConstants()) {
            if (constant.name()
                .equals(name)) {
                return constant;
            }
        }
        return null;
    }

    /**
     * name으로 enum을 조회하는 공통 메서드
     * 
     * @param enumClass enum 클래스 타입
     * @param name 조회할 name 값
     * @param <E> Enum 타입 (CodeEnum을 구현한)
     * @return 일치하는 enum, 없으면 null
     */
    public static <E extends Enum<E> & CodeEnum> E convertByName(String name, Class<E> enumClass) {
        if (name == null) {
            return null;
        }
        for (E constant : enumClass.getEnumConstants()) {
            if (constant.getName()
                .equals(name)) {
                return constant;
            }
        }
        return null;
    }
}
