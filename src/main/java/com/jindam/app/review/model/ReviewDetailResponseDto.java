package com.jindam.app.review.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "후기 상세 응답 모델")
public class ReviewDetailResponseDto {

	@Schema(description = "후기 ID")
	private String id;

	@Schema(description = "예약 ID")
	private String appointmentId;

	@Schema(description = "고객 UID")
	private String customerId;

	@Schema(description = "디자이너 UID")
	private String designerId;

	@Schema(description = "후기 유형 코드 배열 (CodeEnum front 값)")
	private List<String> reviewType;

	@Schema(description = "후기 내용")
	private String reviewContent;

	@Schema(description = "생성 일시")
	private LocalDateTime createAt;

	@Schema(description = "수정 일시")
	private LocalDateTime updateAt;
}
