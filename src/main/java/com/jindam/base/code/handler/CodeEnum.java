package com.jindam.base.code.handler;

public interface CodeEnum {
    String getText();

    default String getCode() {
        return ((Enum<?>) this).name();
    }
}