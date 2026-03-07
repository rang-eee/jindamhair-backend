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
@Schema(description = "제안 디자이너 삭제 요청 모델")
public class OfferDesignerDeleteRequestDto {

	@Schema(description = "제안 ID", required = true)
	private String offerId;

	@Schema(description = "디자이너 UID", required = true)
	private String designerUid;
}
