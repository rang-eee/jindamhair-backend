package com.jindam.app.payment.model;

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
@Schema(description = "결제 조회 요청 모델")
public class PaymentDetailRequestDto extends PagingRequestDto {

	@Schema(description = "결제 ID")
	private String paymentId;

	@Schema(description = "주문 ID")
	private String orderId;

	@Schema(description = "결제 키")
	private String paymentKey;
}
