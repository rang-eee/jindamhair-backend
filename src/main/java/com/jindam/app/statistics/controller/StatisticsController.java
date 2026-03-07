package com.jindam.app.statistics.controller;

import com.jindam.app.statistics.model.*;
import com.jindam.app.statistics.service.StatisticsService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "통계(추천) 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/statistics")
@Slf4j
public class StatisticsController extends MasterController {

	private final StatisticsService statisticsService;

	@Operation(summary = "통계 목록 조회", description = "디자이너 추천 통계 목록을 조회합니다.")
	@GetMapping("")
	public ApiResultDto<List<StatisticsDetailResponseDto>> selectListStatistics(StatisticsDetailRequestDto request) {
		ApiResultDto<List<StatisticsDetailResponseDto>> apiResultVo = new ApiResultDto<>();
		apiResultVo.setData(statisticsService.selectListStatistics(request));
		return apiResultVo;
	}

	@Operation(summary = "통계 생성", description = "디자이너 추천 통계를 생성합니다.")
	@PostMapping("")
	public ApiResultDto<StatisticsDetailResponseDto> insertStatistics(@RequestBody StatisticsInsertRequestDto request) {
		ApiResultDto<StatisticsDetailResponseDto> apiResultVo = new ApiResultDto<>();
		apiResultVo.setData(statisticsService.insertStatistics(request));
		return apiResultVo;
	}

	@Operation(summary = "통계 수정", description = "디자이너 추천 통계를 수정합니다.")
	@PatchMapping("")
	public ApiResultDto<StatisticsDetailResponseDto> updateStatistics(@RequestBody StatisticsUpdateRequestDto request) {
		ApiResultDto<StatisticsDetailResponseDto> apiResultVo = new ApiResultDto<>();
		apiResultVo.setData(statisticsService.updateStatistics(request));
		return apiResultVo;
	}
}
