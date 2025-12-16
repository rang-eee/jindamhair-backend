package com.jindam.base.code;

public interface CodeEnum {
    String getText();

    default String getCode() {
        return ((Enum<?>) this).name();
    }
}