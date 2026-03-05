package com.jindam.app.user.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "디자이너 월별 일정 응답 모델")
public class MonthlyScheduleResponseDto {
    @Schema(description = " 일 (1~31)", example = "")
    private int day;

    @Schema(description = "[밑줄] 오늘 표시", example = "")
    private String todayYn;

    @Schema(description = "[회색] 정기 휴무 요일 (designer_open_day_arr 기준)", example = "")
    private String closeYn;

    @Schema(description = "[빨강] 예약 불가 (특정 휴무일 designer_off_date_arr OR 전체 예약 마감)", example = "")
    private String unavailableYn;

    @Schema(description = "[파랑] 예약 여부 (예약이 1건이라도 존재 시)", example = "")
    private String appointmentYn;

}
