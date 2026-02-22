package com.jindam.app.treatment.model;

import com.jindam.base.code.HairAddTypeCode;
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
@Schema(description = "디자이너 시술 추가 생성 요청 모델")
public class DesignerTreatmentAddDetailResponseDto {

    @Schema(description = "디자이너 시술 추가 ID", example = "")
    private String designerTreatmentAddId;

    @Schema(description = "디자이너 시술 ID", example = "")
    private String designerTreatmentId;

    @Schema(description = "헤어 추가 유형 코드", example = "")
    private HairAddTypeCode hairAddTypeCode;

    @Schema(description = "추가 금액", example = "")
    private String addAmount;

    @Schema(description = "작업 일시", example = "")
    private LocalDateTime workAt;

    @Schema(description = "작업자 ID", example = "")
    private String workId;

    @Schema(description = "삭제 여부", example = "")
    private String deleteYn;

}
