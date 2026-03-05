package com.jindam.app.user.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "디자이너 일별 일정 응답 모델")
public class DailyScheduleResponseDto {
    @Schema(description = "예약 슬롯 시간 (HH:mm 포맷)", example = "09:00")
    private String time;

    @Schema(description = "예약가능여부 (Y/N)", example = "Y")
    private String appointmentYn;

    @Schema(description = "오늘(YYYYMMDD)", example = "20260129")
    private LocalDateTime today;

}
