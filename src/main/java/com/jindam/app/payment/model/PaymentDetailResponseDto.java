package com.jindam.app.payment.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "결제 상세 응답 모델")
public class PaymentDetailResponseDto {

	@Schema(description = "결제 ID")
	private String id;

	@Schema(description = "주문 ID")
	private String orderId;

	@Schema(description = "결제 금액")
	private BigDecimal amount;

	@Schema(description = "결제 키")
	private String paymentKey;

	@Schema(description = "결제 유형 값")
	private String paymentType;

	@Schema(description = "생성 일시")
	private LocalDateTime createAt;

	@Schema(description = "수정 일시")
	private LocalDateTime updateAt;
}
