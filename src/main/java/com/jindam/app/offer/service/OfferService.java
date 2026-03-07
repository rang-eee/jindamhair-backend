package com.jindam.app.offer.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.jindam.app.offer.mapper.OfferMapper;
import com.jindam.app.offer.model.*;
import com.jindam.base.base.PagingService;
import com.jindam.base.code.OfferAgreeStatusCode;
import com.jindam.base.dto.PagingResponseDto;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class OfferService {

	private final OfferMapper offerMapper;

	// ═══════════════════════════════════════════════════
	// 제안 목록 조회 (페이징)
	// ═══════════════════════════════════════════════════
	public PagingResponseDto<OfferDetailResponseDto> selectOffersByUidPaging(OfferDetailRequestDto request) {
		PagingResponseDto<OfferDetailResponseDto> pagingResult = PagingService.findData(offerMapper, "selectOffersByUidPaging", request);

		// 각 offer 에 대해 treatments + designers 조립
		if (pagingResult.getContent() != null) {
			for (OfferDetailResponseDto offer : pagingResult.getContent()) {
				assembleOfferDetails(offer);
			}
		}

		return pagingResult;
	}

	// ═══════════════════════════════════════════════════
	// 제안 단건 조회
	// ═══════════════════════════════════════════════════
	public OfferDetailResponseDto selectOfferById(OfferDetailRequestDto request) {
		OfferDetailResponseDto offer = offerMapper.selectOfferById(request);
		if (offer != null) {
			assembleOfferDetails(offer);
		}
		return offer;
	}

	// ═══════════════════════════════════════════════════
	// 제안 생성
	// ═══════════════════════════════════════════════════
	public OfferDetailResponseDto insertOffer(OfferInsertRequestDto request) {
		// 1) offer 본체 INSERT
		offerMapper.insertOffer(request);

		// 2) offer treatments INSERT (levelCodes1/2/3)
		String offerId = request.getOfferUid(); // insertOffer SQL 에서 생성한 offer_id 를 반환받도록 해야 하지만,
		// 현 구조에서는 SQL RETURNING 또는 selectKey 로 처리. 아래에서 offerUid 기반 최신 조회로 대체.
		// → 실제로는 INSERT SQL 에서 RETURNING offer_id 를 사용하거나 selectKey 사용
		// 여기서는 간단히 INSERT 후 최신건 조회로 응답
		// TODO: selectKey 로 offerId 반환 처리 고도화

		OfferDetailRequestDto detailReq = new OfferDetailRequestDto();
		detailReq.setOfferUid(request.getOfferUid());
		// 최신 건 조회 (임시: uid 기반 최신건)
		OfferDetailResponseDto result = offerMapper.selectOfferById(detailReq);
		if (result != null) {
			assembleOfferDetails(result);
		}
		return result;
	}

	// ═══════════════════════════════════════════════════
	// 제안 수정
	// ═══════════════════════════════════════════════════
	public OfferDetailResponseDto updateOffer(OfferUpdateRequestDto request) {
		offerMapper.updateOffer(request);

		OfferDetailRequestDto detailReq = new OfferDetailRequestDto();
		detailReq.setOfferId(request.getOfferId());
		OfferDetailResponseDto result = offerMapper.selectOfferById(detailReq);
		if (result != null) {
			assembleOfferDetails(result);
		}
		return result;
	}

	// ═══════════════════════════════════════════════════
	// 제안 디자이너 추가
	// ═══════════════════════════════════════════════════
	public void insertOfferDesigner(OfferDesignerInsertRequestDto request) {
		offerMapper.insertOfferDesigner(request);
	}

	// ═══════════════════════════════════════════════════
	// 제안 디자이너 삭제 (soft delete)
	// ═══════════════════════════════════════════════════
	public void deleteOfferDesigner(OfferDesignerDeleteRequestDto request) {
		offerMapper.deleteOfferDesigner(request);
	}

	// ═══════════════════════════════════════════════════
	// 내부: offer 상세 정보 조립 (treatments + designers)
	// ═══════════════════════════════════════════════════
	private void assembleOfferDetails(OfferDetailResponseDto offer) {
		if (offer == null || offer.getId() == null)
			return;

		OfferDetailRequestDto req = new OfferDetailRequestDto();
		req.setOfferId(offer.getId());

		// 시술 코드/타이틀 조립
		List<OfferTreatmentDetailResponseDto> treatments = offerMapper.selectOfferTreatmentsByOfferId(req);
		if (treatments != null && !treatments.isEmpty()) {
			offer.setLevelCodes1(filterByLevel(treatments, 1, false));
			offer.setLevelCodes2(filterByLevel(treatments, 2, false));
			offer.setLevelCodes3(filterByLevel(treatments, 3, false));
			offer.setLevelTitles1(filterByLevel(treatments, 1, true));
			offer.setLevelTitles2(filterByLevel(treatments, 2, true));
			offer.setLevelTitles3(filterByLevel(treatments, 3, true));
		} else {
			offer.setLevelCodes1(new ArrayList<>());
			offer.setLevelCodes2(new ArrayList<>());
			offer.setLevelCodes3(new ArrayList<>());
			offer.setLevelTitles1(new ArrayList<>());
			offer.setLevelTitles2(new ArrayList<>());
			offer.setLevelTitles3(new ArrayList<>());
		}

		// 디자이너 조립
		List<OfferDesignerDetailResponseDto> designers = offerMapper.selectOfferDesignersByOfferId(req);
		if (designers != null && !designers.isEmpty()) {
			offer.setDesigners(designers);

			// designerIds
			List<String> designerIds = designers.stream()
				.map(OfferDesignerDetailResponseDto::getUid)
				.filter(uid -> uid != null)
				.collect(Collectors.toList());
			offer.setDesignerIds(designerIds);

			// designerInfos
			Map<String, Object> designerInfos = new HashMap<>();
			for (OfferDesignerDetailResponseDto d : designers) {
				if (d.getUid() != null) {
					Map<String, Object> info = new HashMap<>();
					info.put("status", d.getCustomOfferRequestType() != null ? d.getCustomOfferRequestType()
						.getFront() : OfferAgreeStatusCode.waiting.getFront());
					designerInfos.put(d.getUid(), info);
				}
			}
			offer.setDesignerInfos(designerInfos);
		} else {
			offer.setDesigners(new ArrayList<>());
			offer.setDesignerIds(new ArrayList<>());
			offer.setDesignerInfos(new HashMap<>());
		}
	}

	private List<String> filterByLevel(List<OfferTreatmentDetailResponseDto> treatments, int level, boolean useName) {
		return treatments.stream()
			.filter(t -> t.getTreatmentLevel() != null && t.getTreatmentLevel() == level)
			.map(t -> useName ? (t.getTreatmentName() != null ? t.getTreatmentName() : t.getTreatmentCode()) : t.getTreatmentCode())
			.filter(v -> v != null)
			.collect(Collectors.toList());
	}
}
