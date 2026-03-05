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
@Schema(description = "디자이너 일정 요청 모델")
public class ScheduleRequestDto {

    @Schema(description = "사용자ID", example = "hs83oVc0fUO1ty5STlowTbcTPFS2")
    private String uid;

    @Schema(description = "입력 년도", example = "2026")
    private String yy;

    @Schema(description = "입력 월", example = "03")
    private String mm;

    @Schema(description = "입력 일", example = "03")
    private String dd;

    @Schema(description = "작업 일시", example = "2026-03-11T17:04:56.082147")
    private LocalDateTime workAt;

    @Schema(description = "작업 ID", example = "hs83oVc0fUO1ty5STlowTbcTPFS2")
    private String workId;

}
