package com.jindam.app.offer.model;

import com.jindam.base.code.OfferAgreeStatusCode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "제안 디자이너 상세 응답 모델")
public class OfferDesignerDetailResponseDto {

	@Schema(description = "제안 디자이너 ID (PK)")
	private String id;

	@Schema(description = "제안 ID")
	private String offerId;

	@Schema(description = "디자이너 UID")
	private String uid;

	@Schema(description = "디자이너 닉네임")
	private String nickname;

	@Schema(description = "시술 메뉴명")
	private String menuName;

	@Schema(description = "지점명")
	private String storeName;

	@Schema(description = "제안 수락 상태 코드")
	private OfferAgreeStatusCode customOfferRequestType;

	@Schema(description = "생성 일시")
	private LocalDateTime createAt;

	@Schema(description = "수정 일시")
	private LocalDateTime updateAt;
}
