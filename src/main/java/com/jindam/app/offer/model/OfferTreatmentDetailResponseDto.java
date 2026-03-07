package com.jindam.app.offer.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "제안 시술 상세 응답 모델")
public class OfferTreatmentDetailResponseDto {

	@Schema(description = "제안 시술 ID")
	private String offerTreatmentId;

	@Schema(description = "제안 ID")
	private String offerId;

	@Schema(description = "시술 레벨 (1, 2, 3)")
	private Integer treatmentLevel;

	@Schema(description = "시술 코드")
	private String treatmentCode;

	@Schema(description = "시술명 (조인)")
	private String treatmentName;
}
