package com.jindam.app.treatment.model;

import com.jindam.base.code.HairAddTypeCode;
import com.jindam.base.code.TreatmentGenderTypeCode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "디자이너 시술 상세 응답 모델")
public class DesignerTreatmentDetailResponseDto {

    @Schema(description = "디자이너 시술 ID", example = "123")
    private String designerTreatmentId;

    @Schema(description = "사용자ID(디자이너 아이디)", example = "123")
    private String uid;

    @Schema(description = "시술 명", example = "123")
    private String treatmentName;

    @Schema(description = "기본 금액", example = "123")
    private String basicAmount;

    @Schema(description = "할인 백분율", example = "123")
    private String discountPt;

    @Schema(description = "할인 금액", example = "123")
    private String discountAmount;

    @Schema(description = "헤어 추가 유형 코드", example = "123")
    private HairAddTypeCode hairAddTypeCode;

    @Schema(description = "추가 금액", example = "123")
    private String addAmount;

    @Schema(description = "총 금액", example = "123")
    private String treatmentTotalAmount;

    @Schema(description = "시술 내용", example = "123")
    private String treatmentContent;

    @Schema(description = "시술 소요 시간", example = "123")
    private String treatmentRequireTime;

    @Schema(description = "시술 사진 파일 ID", example = "123")
    private String treatmentPhotoFileId;

    @Schema(description = "시술 성별 유형 코드", example = "123")
    private TreatmentGenderTypeCode treatmentGenderTypeCode;

    @Schema(description = "할인 여부", example = "123")
    private String discountYn;

    @Schema(description = "추가 여부", example = "123")
    private String addYn;

    @Schema(description = "오픈 여부", example = "123")
    private String openYn;

    @Schema(description = "시술 코드 1", example = "123")
    private String treatmentCode1;

    @Schema(description = "시술 명 1", example = "123")
    private String treatmentName1;

    @Schema(description = "시술 코드 2", example = "123")
    private String treatmentCode2;

    @Schema(description = "시술 명 2", example = "123")
    private String treatmentName2;

    @Schema(description = "시술 코드 3", example = "123")
    private String treatmentCode3;

    @Schema(description = "시술 명 3", example = "123")
    private String treatmentName3;

    @Schema(description = "시술 추가 리스트")
    private List<DesignerTreatmentAddDetailResponseDto> treatmentAddList;

}
