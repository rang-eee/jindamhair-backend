package com.jindam.base.code.handler;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.BeanProperty;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.deser.ContextualDeserializer;

import java.io.IOException;

/**
 * 프론트엔드에서 전달하는 front 코드 문자열을 {@link CodeEnum} 구현 Enum으로 역직렬화하는 Jackson Deserializer.
 *
 * <p>
 * {@code @RequestBody} JSON에서 CodeEnum 필드를 문자열로 받을 때 사용됩니다.
 * </p>
 *
 * <h3>변환 우선순위</h3>
 * <ol>
 * <li>{@link CodeEnum#getFront()} 매칭 (예: {@code "BannerType.layer"})</li>
 * <li>{@link CodeEnum#getCode()} 매칭 (예: {@code "layer"})</li>
 * <li>{@link Enum#name()} fallback (예: {@code "layer"})</li>
 * </ol>
 */
@SuppressWarnings({ "rawtypes", "unchecked" })
public class CodeEnumDeserializer extends JsonDeserializer<CodeEnum> implements ContextualDeserializer {

    private Class<? extends CodeEnum> enumType;

    public CodeEnumDeserializer() {
    }

    public CodeEnumDeserializer(Class<? extends CodeEnum> enumType) {
        this.enumType = enumType;
    }

    @Override
    public JsonDeserializer<?> createContextual(DeserializationContext ctxt, BeanProperty property) throws JsonMappingException {
        Class<?> rawClass = ctxt.getContextualType()
            .getRawClass();
        if (CodeEnum.class.isAssignableFrom(rawClass)) {
            return new CodeEnumDeserializer((Class<? extends CodeEnum>) rawClass);
        }
        return this;
    }

    @Override
    public CodeEnum deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
        String value = p.getValueAsString();
        if (value == null || value.isBlank()) {
            return null;
        }

        String trimmed = value.trim();

        if (enumType == null || !enumType.isEnum()) {
            return null;
        }

        CodeEnum[] constants = enumType.getEnumConstants();

        // 1) front 값 매칭 (예: "BannerType.layer")
        for (CodeEnum constant : constants) {
            if (trimmed.equals(constant.getFront())) {
                return constant;
            }
        }

        // 2) code 값 매칭 (예: "layer")
        for (CodeEnum constant : constants) {
            if (trimmed.equals(constant.getCode())) {
                return constant;
            }
        }

        // 3) enum name fallback
        try {
            return (CodeEnum) Enum.valueOf((Class) enumType, trimmed);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
