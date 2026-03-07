package com.jindam.app.review.model;

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
@Schema(description = "후기 조회 요청 모델")
public class ReviewDetailRequestDto extends PagingRequestDto {

	@Schema(description = "후기 ID")
	private String reviewId;

	@Schema(description = "예약 ID")
	private String appointmentId;

	@Schema(description = "고객 UID")
	private String customerId;

	@Schema(description = "디자이너 UID")
	private String designerId;
}
