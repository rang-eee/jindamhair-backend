package com.jindam.app.statistics.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "통계 조회 요청 모델")
public class StatisticsDetailRequestDto {

	@Schema(description = "통계 ID")
	private String id;

	@Schema(description = "디자이너 UID")
	private String designerUid;
}
