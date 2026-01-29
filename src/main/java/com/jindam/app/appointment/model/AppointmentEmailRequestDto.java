package com.jindam.app.appointment.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "예약 이메일 조회 요청 모델")
public class AppointmentEmailRequestDto {
    @Schema(description = "고객 이메일", example = "test@example.com")
    private String userEmail;
}
