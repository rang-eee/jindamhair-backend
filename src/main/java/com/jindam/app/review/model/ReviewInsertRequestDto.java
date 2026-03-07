package com.jindam.app.review.model;

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
@Schema(description = "후기 생성 요청 모델")
public class ReviewInsertRequestDto {

	@Schema(description = "예약 ID", required = true)
	private String appointmentId;

	@Schema(description = "고객 UID", required = true)
	private String customerId;

	@Schema(description = "디자이너 UID", required = true)
	private String designerId;

	@Schema(description = "후기 유형 목록 (front 값, e.g. 'ReviewType.friendlyService')")
	private List<String> reviewType;

	@Schema(description = "후기 내용")
	private String reviewContent;
}
