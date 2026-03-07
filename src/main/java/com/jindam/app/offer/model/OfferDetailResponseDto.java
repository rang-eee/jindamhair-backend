package com.jindam.app.offer.model;

import com.jindam.base.code.OfferAgreeStatusCode;
import com.jindam.base.code.OfferStatusCode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "제안 상세 응답 모델")
public class OfferDetailResponseDto {

	// ──────────────────────────────────────────────
	// Flutter OfferModelKey 기준 필드 (JSON key 일치)
	// ──────────────────────────────────────────────

	@Schema(description = "제안 ID")
	private String id;

	@Schema(description = "제안 고객 UID")
	private String offerUid;

	@Schema(description = "제안 상태 코드")
	private OfferStatusCode offerStatusType;

	@Schema(description = "제안 일시")
	private LocalDateTime offerAt;

	@Schema(description = "제안 금액")
	private Integer price;

	@Schema(description = "제안 위치 주소")
	private String offerLocationAddress;

	@Schema(description = "제안 위치 거리")
	private Double offerLocationDistance;

	@Schema(description = "제안 위치 위도")
	private Double offerLocationLatitude;

	@Schema(description = "제안 위치 경도")
	private Double offerLocationLongitude;

	@Schema(description = "제안 메모")
	private String offerMemo;

	@Schema(description = "생성 일시")
	private LocalDateTime createAt;

	@Schema(description = "수정 일시")
	private LocalDateTime updateAt;

	// ──────────────────────────────────────────────
	// 시술 레벨별 코드/타이틀 (Service 에서 조립)
	// ──────────────────────────────────────────────

	@Schema(description = "시술 레벨1 코드 목록")
	private List<String> levelCodes1;

	@Schema(description = "시술 레벨2 코드 목록")
	private List<String> levelCodes2;

	@Schema(description = "시술 레벨3 코드 목록")
	private List<String> levelCodes3;

	@Schema(description = "시술 레벨1 타이틀 목록")
	private List<String> levelTitles1;

	@Schema(description = "시술 레벨2 타이틀 목록")
	private List<String> levelTitles2;

	@Schema(description = "시술 레벨3 타이틀 목록")
	private List<String> levelTitles3;

	// ──────────────────────────────────────────────
	// 디자이너 관련 (Service 에서 조립)
	// ──────────────────────────────────────────────

	@Schema(description = "디자이너 UID 목록")
	private List<String> designerIds;

	@Schema(description = "디자이너 정보 맵 {uid: {status:...}}")
	private Map<String, Object> designerInfos;

	@Schema(description = "디자이너 상세 목록")
	private List<OfferDesignerDetailResponseDto> designers;
}
