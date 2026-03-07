package com.jindam.app.payment.mapper;

import com.jindam.app.payment.model.*;

import java.util.List;

public interface PaymentMapper {

	PaymentDetailResponseDto selectPaymentById(PaymentDetailRequestDto request);

	List<PaymentDetailResponseDto> selectPaymentsPaging(PaymentDetailRequestDto request);

	int selectPaymentsPagingCount(PaymentDetailRequestDto request);

	int insertPayment(PaymentInsertRequestDto request);
}
