package com.jindam.app.offer.model;

import com.jindam.base.dto.PagingRequestDto;
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
@Schema(description = "제안 조회 요청 모델")
public class OfferDetailRequestDto extends PagingRequestDto {

	@Schema(description = "제안 ID")
	private String offerId;

	@Schema(description = "제안 고객 UID")
	private String offerUid;

	@Schema(description = "디자이너 UID (디자이너별 제안 조회 시)")
	private String designerUid;
}
