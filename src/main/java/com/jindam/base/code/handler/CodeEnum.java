package com.jindam.base.code.handler;

public interface CodeEnum {
    String getText();

    String getFront();

    default String getCode() {
        String front = getFront();
        if (front == null || front.trim()
            .isEmpty()) {
            return ((Enum<?>) this).name();
        }
        String trimmed = front.trim();
        int lastDot = trimmed.lastIndexOf('.');
        if (lastDot >= 0 && lastDot < trimmed.length() - 1) {
            return trimmed.substring(lastDot + 1);
        }
        return trimmed;
    }
}