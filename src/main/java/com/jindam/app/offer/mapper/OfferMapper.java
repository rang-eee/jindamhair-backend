package com.jindam.app.offer.mapper;

import com.jindam.app.offer.model.*;

import java.util.List;

/**
 * OfferMapper 인터페이스
 *
 * <p>
 * tb_offer, tb_offer_treatment, tb_offer_designer 관련 CRUD 및 페이징 처리를 위한 메서드를 정의합니다.
 * </p>
 */
public interface OfferMapper {

	// ─── Offer 기본 ─────────────────────────

	OfferDetailResponseDto selectOfferById(OfferDetailRequestDto request);

	List<OfferDetailResponseDto> selectOffersByUidPaging(OfferDetailRequestDto request);

	int selectOffersByUidPagingCount(OfferDetailRequestDto request);

	int insertOffer(OfferInsertRequestDto request);

	int updateOffer(OfferUpdateRequestDto request);

	// ─── Offer Treatment ────────────────────

	List<OfferTreatmentDetailResponseDto> selectOfferTreatmentsByOfferId(OfferDetailRequestDto request);

	int insertOfferTreatment(OfferTreatmentDetailResponseDto request);

	int deleteOfferTreatmentsByOfferId(OfferDetailRequestDto request);

	// ─── Offer Designer ─────────────────────

	List<OfferDesignerDetailResponseDto> selectOfferDesignersByOfferId(OfferDetailRequestDto request);

	int insertOfferDesigner(OfferDesignerInsertRequestDto request);

	int deleteOfferDesigner(OfferDesignerDeleteRequestDto request);
}
