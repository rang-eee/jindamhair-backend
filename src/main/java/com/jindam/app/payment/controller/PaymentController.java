package com.jindam.app.payment.controller;

import com.jindam.app.payment.model.*;
import com.jindam.app.payment.service.PaymentService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Tag(name = "결제 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/payments")
@Slf4j
public class PaymentController extends MasterController {

	private final PaymentService paymentService;

	@Operation(summary = "결제 목록 조회", description = "결제 목록을 조회합니다. 페이징을 지원합니다.")
	@GetMapping("")
	public ApiResultDto<PagingResponseDto<PaymentDetailResponseDto>> selectPayments(PaymentDetailRequestDto request) {
		ApiResultDto<PagingResponseDto<PaymentDetailResponseDto>> apiResultVo = new ApiResultDto<>();
		PagingResponseDto<PaymentDetailResponseDto> result = paymentService.selectPaymentsPaging(request);
		apiResultVo.setData(result);
		return apiResultVo;
	}

	@Operation(summary = "결제 생성", description = "결제 데이터를 생성합니다.")
	@PostMapping("")
	public ApiResultDto<PaymentDetailResponseDto> insertPayment(@RequestBody PaymentInsertRequestDto request) {
		ApiResultDto<PaymentDetailResponseDto> apiResultVo = new ApiResultDto<>();
		PaymentDetailResponseDto result = paymentService.insertPayment(request);
		apiResultVo.setData(result);
		return apiResultVo;
	}
}
