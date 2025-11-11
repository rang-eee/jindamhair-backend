package com.jindam.app.common.mapper;

import com.jindam.app.common.model.HistoryLogRequestDto;

public interface HistoryLogMapper {

    int insertErrorLog(HistoryLogRequestDto request);

}