package com.jindam.app.appointment.controller;

import com.jindam.app.appointment.model.*;
import com.jindam.app.appointment.service.AppointmentService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "예약 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/appointment")
@Slf4j
public class AppointmentController extends MasterController {

    private final AppointmentService appointmentService;

    @Operation(summary = "예약 내역 목록 조회", description = "고객의 예약 내역을 조회합니다.")
    @GetMapping("")
    public ApiResultDto<AppointmentDetailResponseDto> selectAppointment(AppointmentDetailRequestDto request) {
        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        AppointmentDetailResponseDto result;
        result = appointmentService.selectAppointmentById(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }

    @Operation(summary = "이메일 기반 예약 내역 목록 조회", description = "이메일로 고객의 예약 내역을 조회합니다.")
    @GetMapping("/email")
    public ApiResultDto<List<AppointmentDetailResponseDto>> selectAppointmentByEmail(AppointmentEmailRequestDto request) {
        ApiResultDto<List<AppointmentDetailResponseDto>> apiResultVo = new ApiResultDto<>();
        List<AppointmentDetailResponseDto> result;
        result = appointmentService.selectAppointmentByEmail(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "예약 생성 요청 처리", description = "예약 건을 생성합니다.")
    @PostMapping("")
    public ApiResultDto<AppointmentDetailResponseDto> insertAppointment(AppointmentInsertRequestDto request) {
        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        AppointmentDetailResponseDto result;

        result = appointmentService.insertAppointment(request);

        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "예약 수정 요청 처리", description = "예약 건을 수정합니다.")
    @PatchMapping("")
    public void updateAppointment(AppointmentUpdateRequestDto request) {
        //        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        //        AppointmentDetailResponseDto result;
        appointmentService.updateAppointment(request);

    }

    @Operation(summary = "예약 삭제 요청 처리", description = "예약 건을 삭제합니다.")
    @DeleteMapping("")
    public void deleteAppointment(AppointmentDeleteRequestDto request) {
        //        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        //        AppointmentDetailResponseDto result;
        appointmentService.deleteAppointment(request);
    }
}