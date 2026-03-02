package com.jindam.base.code.handler;

import org.springframework.core.convert.converter.Converter;
import org.springframework.core.convert.converter.ConverterFactory;

/**
 * 프론트엔드에서 전달하는 front 코드 문자열을 백엔드 Enum으로 변환하는 ConverterFactory.
 *
 * <p>Spring {@code @RequestParam}, {@code @ModelAttribute} 등의 바인딩 시 자동 적용됩니다.</p>
 *
 * <h3>변환 우선순위</h3>
 * <ol>
 *   <li>{@link CodeEnum#getFront()} 매칭 (예: {@code "BannerType.layer"} → {@code BannerTypeCode.layer})</li>
 *   <li>{@link CodeEnum#getCode()} 매칭 (예: {@code "layer"} → {@code BannerTypeCode.layer})</li>
 *   <li>{@link Enum#name()} fallback (예: {@code "layer"} → {@code BannerTypeCode.layer})</li>
 * </ol>
 *
 * <h3>등록 방법</h3>
 * <pre>
 * &#64;Override
 * public void addFormatters(FormatterRegistry registry) {
 *     registry.addConverterFactory(new CodeEnumConverterFactory());
 * }
 * </pre>
 */
@SuppressWarnings({"rawtypes", "unchecked"})
public class CodeEnumConverterFactory implements ConverterFactory<String, Enum> {

    @Override
    public <T extends Enum> Converter<String, T> getConverter(Class<T> targetType) {
        return source -> convert(source, targetType);
    }

    private <T extends Enum> T convert(String source, Class<T> targetType) {
        if (source == null || source.isBlank()) {
            return null;
        }

        String trimmed = source.trim();

        // CodeEnum 구현체인 경우 front / code 매칭 우선
        if (CodeEnum.class.isAssignableFrom(targetType)) {
            T[] constants = targetType.getEnumConstants();

            // 1) front 값 매칭 (예: "BannerType.layer")
            for (T constant : constants) {
                CodeEnum ce = (CodeEnum) constant;
                if (trimmed.equals(ce.getFront())) {
                    return constant;
                }
            }

            // 2) code 값 매칭 (front에서 '.' 뒤 부분, 예: "layer")
            for (T constant : constants) {
                CodeEnum ce = (CodeEnum) constant;
                if (trimmed.equals(ce.getCode())) {
                    return constant;
                }
            }
        }

        // 3) enum name fallback
        try {
            return (T) Enum.valueOf(targetType, trimmed);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
