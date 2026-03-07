package com.jindam.app.statistics.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "통계 생성 요청 모델")
public class StatisticsInsertRequestDto {

	@Schema(description = "통계 ID (selectKey 로 자동 생성)")
	private String id;

	@Schema(description = "디자이너 UID")
	private String designerUid;

	@Schema(description = "디자이너 추천 횟수")
	private Integer designerRecommendCount;

	@Schema(description = "추천으로 가입한 유저 UID 목록")
	private List<String> joinUserUids;
}
