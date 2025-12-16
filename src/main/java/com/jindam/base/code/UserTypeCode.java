package com.jindam.base.code;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum UserTypeCode implements CodeEnum {
    USTP001("고객"), //
    USTP002("디자이너"), //
    ;

    private final String text;

    public String toCode() {
        return name();
    }
}