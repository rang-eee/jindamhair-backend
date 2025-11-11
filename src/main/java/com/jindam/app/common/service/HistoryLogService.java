package com.jindam.app.common.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.jindam.app.common.mapper.HistoryLogMapper;
import com.jindam.app.common.model.HistoryLogRequestDto;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class HistoryLogService {
    private final HistoryLogMapper historyLogMapper;

    public void insertErrorLog(HistoryLogRequestDto request) {
        historyLogMapper.insertErrorLog(request);
    }
}
