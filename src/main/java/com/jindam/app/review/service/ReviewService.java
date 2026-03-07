package com.jindam.app.review.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.jindam.app.review.mapper.ReviewMapper;
import com.jindam.app.review.model.*;
import com.jindam.base.base.PagingService;
import com.jindam.base.code.ReviewTypeCode;
import com.jindam.base.dto.PagingResponseDto;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewService {

	private final ReviewMapper reviewMapper;

	// ═══════════════════════════════════════════════════
	// 후기 목록 조회 (페이징)
	// ═══════════════════════════════════════════════════
	public PagingResponseDto<ReviewDetailResponseDto> selectReviewsPaging(ReviewDetailRequestDto request) {
		return PagingService.findData(reviewMapper, "selectReviewsPaging", request);
	}

	// ═══════════════════════════════════════════════════
	// 후기 생성
	// ═══════════════════════════════════════════════════
	public ReviewDetailResponseDto insertReview(ReviewInsertRequestDto request) {
		// 1) tb_review INSERT
		reviewMapper.insertReview(request);

		// 2) tb_designer_review count 증가
		// Flutter가 보내는 reviewType: ["ReviewType.friendlyService", ...]
		// → CodeEnum front 값에서 enum name 추출
		if (request.getReviewType() != null && request.getDesignerId() != null) {
			for (String frontValue : request.getReviewType()) {
				String enumName = resolveEnumName(frontValue);
				if (enumName != null) {
					DesignerReviewUpsertDto upsertDto = new DesignerReviewUpsertDto();
					upsertDto.setUid(request.getDesignerId());
					upsertDto.setReviewTypeCode(enumName);
					reviewMapper.upsertDesignerReviewCount(upsertDto);
				}
			}
		}

		// 3) 결과 조회
		ReviewDetailRequestDto detailReq = new ReviewDetailRequestDto();
		detailReq.setAppointmentId(request.getAppointmentId());
		ReviewDetailResponseDto result = reviewMapper.selectReviewById(detailReq);
		return result;
	}

	/**
	 * "ReviewType.friendlyService" → "friendlyService" 변환 CodeEnum front 값에서 enum name 추출
	 */
	private String resolveEnumName(String frontValue) {
		if (frontValue == null)
			return null;

		// front 값으로 직접 매칭 시도
		for (ReviewTypeCode code : ReviewTypeCode.values()) {
			if (code.getFront()
				.equals(frontValue)) {
				return code.name();
			}
		}

		// "ReviewType." prefix 제거 후 재시도
		if (frontValue.contains(".")) {
			String name = frontValue.substring(frontValue.lastIndexOf('.') + 1);
			try {
				return ReviewTypeCode.valueOf(name)
					.name();
			} catch (IllegalArgumentException e) {
				log.warn("Unknown ReviewType front value: {}", frontValue);
			}
		}

		return frontValue; // 그대로 반환 (최후 수단)
	}
}
