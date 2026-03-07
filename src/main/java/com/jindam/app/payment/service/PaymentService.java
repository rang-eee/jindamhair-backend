package com.jindam.app.payment.service;

import org.springframework.stereotype.Service;

import com.jindam.app.payment.mapper.PaymentMapper;
import com.jindam.app.payment.model.*;
import com.jindam.base.base.PagingService;
import com.jindam.base.dto.PagingResponseDto;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

	private final PaymentMapper paymentMapper;

	public PagingResponseDto<PaymentDetailResponseDto> selectPaymentsPaging(PaymentDetailRequestDto request) {
		return PagingService.findData(paymentMapper, "selectPaymentsPaging", request);
	}

	public PaymentDetailResponseDto insertPayment(PaymentInsertRequestDto request) {
		paymentMapper.insertPayment(request);

		// 최신 건 조회 반환
		PaymentDetailRequestDto detailReq = new PaymentDetailRequestDto();
		detailReq.setPaymentKey(request.getPaymentKey());
		return paymentMapper.selectPaymentById(detailReq);
	}
}
