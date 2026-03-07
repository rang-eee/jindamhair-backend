package com.jindam.app.review.controller;

import com.jindam.app.review.model.*;
import com.jindam.app.review.service.ReviewService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Tag(name = "후기 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/reviews")
@Slf4j
public class ReviewController extends MasterController {

	private final ReviewService reviewService;

	@Operation(summary = "후기 목록 조회", description = "디자이너 UID 또는 예약 ID로 후기 목록을 조회합니다. 페이징을 지원합니다.")
	@GetMapping("")
	public ApiResultDto<PagingResponseDto<ReviewDetailResponseDto>> selectReviews(ReviewDetailRequestDto request) {
		ApiResultDto<PagingResponseDto<ReviewDetailResponseDto>> apiResultVo = new ApiResultDto<>();
		PagingResponseDto<ReviewDetailResponseDto> result = reviewService.selectReviewsPaging(request);
		apiResultVo.setData(result);
		return apiResultVo;
	}

	@Operation(summary = "후기 생성", description = "후기를 생성하고, 디자이너 후기 카운트를 업데이트합니다.")
	@PostMapping("")
	public ApiResultDto<ReviewDetailResponseDto> insertReview(@RequestBody ReviewInsertRequestDto request) {
		ApiResultDto<ReviewDetailResponseDto> apiResultVo = new ApiResultDto<>();
		ReviewDetailResponseDto result = reviewService.insertReview(request);
		apiResultVo.setData(result);
		return apiResultVo;
	}
}
