package com.jindam.app.statistics.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "통계 상세 응답 모델")
public class StatisticsDetailResponseDto {

	@Schema(description = "통계 ID")
	private String id;

	@Schema(description = "디자이너 UID")
	private String designerUid;

	@Schema(description = "디자이너 추천 횟수")
	private Integer designerRecommendCount;

	@Schema(description = "추천으로 가입한 유저 UID 목록")
	private List<String> joinUserUids;

	@Schema(description = "생성 일시")
	private LocalDateTime createAt;

	@Schema(description = "수정 일시")
	private LocalDateTime updateAt;
}
