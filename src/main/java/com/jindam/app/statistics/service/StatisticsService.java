package com.jindam.app.statistics.service;

import com.jindam.app.statistics.mapper.StatisticsMapper;
import com.jindam.app.statistics.model.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class StatisticsService {

	private final StatisticsMapper statisticsMapper;

	/**
	 * 통계 목록 조회 (전체 또는 designerUid 필터)
	 */
	public List<StatisticsDetailResponseDto> selectListStatistics(StatisticsDetailRequestDto request) {
		return statisticsMapper.selectListStatistics(request);
	}

	/**
	 * 통계 생성 후 생성된 데이터 반환
	 */
	public StatisticsDetailResponseDto insertStatistics(StatisticsInsertRequestDto request) {
		statisticsMapper.insertStatistics(request);
		// selectKey 로 request.id 에 생성된 PK 가 세팅됨
		return statisticsMapper.selectStatisticsById(request.getId());
	}

	/**
	 * 통계 수정 후 수정된 데이터 반환
	 */
	public StatisticsDetailResponseDto updateStatistics(StatisticsUpdateRequestDto request) {
		statisticsMapper.updateStatistics(request);
		return statisticsMapper.selectStatisticsById(request.getId());
	}
}
