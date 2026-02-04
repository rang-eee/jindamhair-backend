package com.jindam.base.code.handler;

public interface CodeEnum {
    String getText();

    String getFront();

    default String getCode() {
        return ((Enum<?>) this).name();
    }
}