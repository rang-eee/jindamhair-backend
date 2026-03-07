package com.jindam.app.payment.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "결제 생성 요청 모델")
public class PaymentInsertRequestDto {

	@Schema(description = "주문 ID")
	private String orderId;

	@Schema(description = "결제 금액")
	private BigDecimal amount;

	@Schema(description = "결제 키")
	private String paymentKey;

	@Schema(description = "결제 유형 값")
	private String paymentType;

	@Schema(description = "생성자 UID")
	private String createId;
}
