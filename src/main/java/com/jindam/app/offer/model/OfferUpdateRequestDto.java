package com.jindam.app.offer.model;

import com.jindam.base.code.OfferStatusCode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "제안 수정 요청 모델")
public class OfferUpdateRequestDto {

	@Schema(description = "제안 ID", required = true)
	private String offerId;

	@Schema(description = "제안 상태 코드")
	private OfferStatusCode offerStatusType;

	@Schema(description = "제안 일시")
	private LocalDateTime offerAt;

	@Schema(description = "제안 금액")
	private Integer price;

	@Schema(description = "제안 위치 주소")
	private String offerLocationAddress;

	@Schema(description = "제안 위치 거리")
	private Double offerLocationDistance;

	@Schema(description = "제안 위치 위도")
	private Double offerLocationLatitude;

	@Schema(description = "제안 위치 경도")
	private Double offerLocationLongitude;

	@Schema(description = "제안 메모")
	private String offerMemo;

	@Schema(description = "수정자 UID")
	private String updateId;
}
