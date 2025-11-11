package com.jindam.app.common.model;

import java.time.LocalDateTime;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "HistoryLogRequestDto")
public class HistoryLogRequestDto {

    @Schema(description = "요청 정보", example = "requestInfo")
    private String requestInfo;

    @Schema(description = "생성자", example = "system")
    private Long createId;

    @Schema(description = "생성일시", example = "system")
    private LocalDateTime createAt;

}
