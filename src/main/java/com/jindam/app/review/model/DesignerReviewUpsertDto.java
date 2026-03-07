package com.jindam.app.review.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "디자이너 후기 카운트 upsert 모델")
public class DesignerReviewUpsertDto {

	@Schema(description = "디자이너 UID")
	private String uid;

	@Schema(description = "후기 유형 코드 (enum name, e.g. 'friendlyService')")
	private String reviewTypeCode;
}
