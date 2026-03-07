package com.jindam.app.review.mapper;

import com.jindam.app.review.model.*;

import java.util.List;

public interface ReviewMapper {

	ReviewDetailResponseDto selectReviewById(ReviewDetailRequestDto request);

	List<ReviewDetailResponseDto> selectReviewsPaging(ReviewDetailRequestDto request);

	int selectReviewsPagingCount(ReviewDetailRequestDto request);

	int insertReview(ReviewInsertRequestDto request);

	/**
	 * tb_designer_review 의 review_count 를 +1 증가
	 */
	int upsertDesignerReviewCount(DesignerReviewUpsertDto request);
}
