package com.jindam.app.offer.controller;

import com.jindam.app.offer.model.*;
import com.jindam.app.offer.service.OfferService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Tag(name = "제안 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/offers")
@Slf4j
public class OfferController extends MasterController {

	private final OfferService offerService;

	// ─── GET /offers ─────────────────────────
	@Operation(summary = "제안 목록 조회", description = "고객 UID 또는 디자이너 UID로 제안 목록을 조회합니다. 페이징을 지원합니다.")
	@GetMapping("")
	public ApiResultDto<PagingResponseDto<OfferDetailResponseDto>> selectOffers(OfferDetailRequestDto request) {
		ApiResultDto<PagingResponseDto<OfferDetailResponseDto>> apiResultVo = new ApiResultDto<>();
		PagingResponseDto<OfferDetailResponseDto> result = offerService.selectOffersByUidPaging(request);
		apiResultVo.setData(result);
		return apiResultVo;
	}

	// ─── POST /offers ────────────────────────
	@Operation(summary = "제안 생성", description = "새로운 제안을 생성합니다.")
	@PostMapping("")
	public ApiResultDto<OfferDetailResponseDto> insertOffer(@RequestBody OfferInsertRequestDto request) {
		ApiResultDto<OfferDetailResponseDto> apiResultVo = new ApiResultDto<>();
		OfferDetailResponseDto result = offerService.insertOffer(request);
		apiResultVo.setData(result);
		return apiResultVo;
	}

	// ─── PATCH /offers ───────────────────────
	@Operation(summary = "제안 수정", description = "기존 제안을 수정합니다.")
	@PatchMapping("")
	public ApiResultDto<OfferDetailResponseDto> updateOffer(@RequestBody OfferUpdateRequestDto request) {
		ApiResultDto<OfferDetailResponseDto> apiResultVo = new ApiResultDto<>();
		OfferDetailResponseDto result = offerService.updateOffer(request);
		apiResultVo.setData(result);
		return apiResultVo;
	}

	// ─── POST /offers/designers ──────────────
	@Operation(summary = "제안 디자이너 추가", description = "제안에 디자이너를 추가합니다.")
	@PostMapping("/designers")
	public ApiResultDto<Object> insertOfferDesigner(@RequestBody OfferDesignerInsertRequestDto request) {
		ApiResultDto<Object> apiResultVo = new ApiResultDto<>();
		offerService.insertOfferDesigner(request);
		return apiResultVo;
	}

	// ─── DELETE /offers/designers ────────────
	@Operation(summary = "제안 디자이너 삭제", description = "제안에서 디자이너를 삭제(soft delete)합니다.")
	@DeleteMapping("/designers")
	public ApiResultDto<Object> deleteOfferDesigner(OfferDesignerDeleteRequestDto request) {
		ApiResultDto<Object> apiResultVo = new ApiResultDto<>();
		offerService.deleteOfferDesigner(request);
		return apiResultVo;
	}
}
