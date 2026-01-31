package com.jindam.app.appointment.model;

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
@Schema(description = "예약 상세 생성 요청 모델")
public class AppointmentSignInsertRequestDto {
    @Schema(description = "예약 서명 ID", example = "")
    private String appointmentSignId;

    @Schema(description = "예약 ID", example = "")
    private String appointmentId;

    @Schema(description = "서명 오프셋 X", example = "")
    private String signOffsetX;

    @Schema(description = "서명 오프셋 Y", example = "")
    private String signOffsetY;

    @Schema(description = "서명 사이즈", example = "")
    private String signSize;

    @Schema(description = "서명 색상", example = "")
    private String signColor;

    @Schema(description = "정렬 순서", example = "")
    private String sortOrder;

    @Schema(description = "작업 일시", example = "")
    private LocalDateTime workAt;

    @Schema(description = "작업자 ID", example = "")
    private String workId;

}
