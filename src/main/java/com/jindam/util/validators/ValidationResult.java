package com.jindam.util.validators;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ValidationResult {

    private boolean isValid; // 검증 결과
    private String message; // 검증 실패 메시지
}
