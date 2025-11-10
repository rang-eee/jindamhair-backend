package com.jindam.util.validators;

import com.jindam.base.message.Message;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ValidationParameters {
    private String field;

    @Builder.Default
    private Validator.Format format = Validator.Format.NONE;

    @Builder.Default
    private boolean notEmpty = false;

    @Builder.Default
    private Integer size = -1;

    @Builder.Default
    private Integer minSize = -1;

    @Builder.Default
    private Integer maxSize = -1;

    @Builder.Default
    private String notEmptyMsg = "{validation.empty}"; // 기본 메시지 키

    @Builder.Default
    private String sizeMsg = "{validation.size.exact}";

    @Builder.Default
    private String minSizeMsg = "{validation.size.min}";

    @Builder.Default
    private String maxSizeMsg = "{validation.size.max}";

    @Builder.Default
    private String formatMsg = "{validation.format.invalid}";

    @Builder.Default
    private String pattern = "";

    @Builder.Default
    private String patternMsg = "{validation.pattern.invalid}";

    // 메시지 키를 처리하는 메서드 추가
    public String getMessage(String key, Object... args) {
        if (key.startsWith("{") && key.endsWith("}")) {
            String actualKey = key.substring(1, key.length() - 1); // {와 } 제거
            return Message.getMessage(actualKey, args); // 메시지 변환
        }
        return key; // 메시지 키가 아니면 그대로 반환
    }
}
