package com.jindam.app.statistics.mapper;

import com.jindam.app.statistics.model.*;

import java.util.List;

public interface StatisticsMapper {

	StatisticsDetailResponseDto selectStatisticsById(String id);

	List<StatisticsDetailResponseDto> selectListStatistics(StatisticsDetailRequestDto request);

	int insertStatistics(StatisticsInsertRequestDto request);

	int updateStatistics(StatisticsUpdateRequestDto request);
}
