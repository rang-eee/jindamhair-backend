package com.jindam.app.appointment.service;

import com.jindam.app.appointment.mapper.AppointmentMapper;
import com.jindam.app.appointment.model.AppointmentDetailRequestDto;
import com.jindam.app.appointment.model.AppointmentDetailResponseDto;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class AppointmentService extends PagingService {
    private final AppointmentMapper bannerMapper;

    public AppointmentDetailResponseDto selectBanner(AppointmentDetailRequestDto request) {
        AppointmentDetailResponseDto result;
        result = bannerMapper.selectBanner(request);

        return result;
    }

}
