package com.jindam.app.appointment.service;

import com.jindam.app.appointment.mapper.AppointmentMapper;
import com.jindam.app.appointment.model.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class AppointmentService {
    private final AppointmentMapper appointmentMapper;

    public AppointmentDetailResponseDto selectAppointmentById(AppointmentDetailRequestDto request) {
        AppointmentDetailResponseDto result;
        result = appointmentMapper.selectAppointmentById(request);

        return result;
    }

    public AppointmentDetailResponseDto insertAppointment(AppointmentInsertRequestDto request) {

        int result;
        result = appointmentMapper.insertAppointment(request);

        if (result > 0) {
            AppointmentDetailRequestDto insertRequestDto = AppointmentDetailRequestDto.from(request);

            AppointmentDetailResponseDto success = appointmentMapper.selectAppointmentById(insertRequestDto);
            return success;
        } else {
            return null;
        }
    }

    public AppointmentDetailResponseDto updateAppointment(AppointmentUpdateRequestDto request) {

        int result;
        result = appointmentMapper.updateAppointment(request);

        if (result > 0) {
            AppointmentDetailRequestDto insertRequestDto = AppointmentDetailRequestDto.from(request);

            AppointmentDetailResponseDto success = appointmentMapper.selectAppointmentById(insertRequestDto);
            return success;
        } else {
            return null;
        }
    }

    public AppointmentDetailResponseDto deleteAppointment(AppointmentDeleteRequestDto request) {

        int result;
        result = appointmentMapper.deleteAppointment(request);

        if (result > 0) {
            AppointmentDetailRequestDto insertRequestDto = AppointmentDetailRequestDto.from(request);

            AppointmentDetailResponseDto success = appointmentMapper.selectAppointmentById(insertRequestDto);
            return success;
        } else {
            return null;
        }
    }

}
