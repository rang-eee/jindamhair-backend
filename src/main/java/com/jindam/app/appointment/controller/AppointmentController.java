package com.jindam.app.appointment.controller;

import com.jindam.app.appointment.model.*;
import com.jindam.app.appointment.service.AppointmentService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;
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

    @Operation(summary = "예약 목록 조회", description = "예약 ID 로 조회합니다.")
    @GetMapping("")
    public ApiResultDto<AppointmentDetailResponseDto> selectAppointment(AppointmentDetailRequestDto request) {
        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        AppointmentDetailResponseDto result;
        result = appointmentService.selectAppointmentById(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }

    @Operation(summary = "예약 목록 조회", description = "고객ID 로 조회합니다. 페이징을 지원합니다.")
    @GetMapping("/customer")
    public ApiResultDto<PagingResponseDto<AppointmentDetailResponseDto>> selectAppointmentByCustId(AppointmentDetailRequestDto request) {
        ApiResultDto<PagingResponseDto<AppointmentDetailResponseDto>> apiResultVo = new ApiResultDto<>();
        PagingResponseDto<AppointmentDetailResponseDto> result;
        result = appointmentService.selectAppointmentByCustIdPaging(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "디자이너 예약 관리 목록 조회", description = "디자이너ID로 조회합니다. 페이징을 조회합니다.")
    @GetMapping("/designer")
    public ApiResultDto<PagingResponseDto<AppointmentDetailResponseDto>> selectAppointmentByDesignerId(AppointmentDetailRequestDto request) {
        ApiResultDto<PagingResponseDto<AppointmentDetailResponseDto>> apiResultVo = new ApiResultDto<>();
        PagingResponseDto<AppointmentDetailResponseDto> result;
        result = appointmentService.selectAppointmentByDesignerIdPaging(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "이메일 기반 예약 내역 목록 조회", description = "주니 테스트로 생성된  api.")
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

    @Operation(summary = "예약 변경 처리", description = "예약 건을 변경합니다. (알림포함)")
    @PatchMapping("")
    public void updateAppointment(AppointmentUpdateRequestDto request) {
        //        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        //        AppointmentDetailResponseDto result;
        appointmentService.updateAppointment(request);

    }

    //@Operation(summary = "예약 수정 처리", description = "예약 데이터를 수정합니다.")

    @Operation(summary = "예약 확정 처리", description = "예약 건을 완료상태로 변경합니다.")
    @PatchMapping("/confirm")
    public void confirmAppointment(AppointmentInsertRequestDto request) {
        appointmentService.confirmAppointment(request);
    }

    @Operation(summary = "예약 삭제 요청 처리", description = "예약 건을 삭제합니다.")
    @DeleteMapping("")
    public void deleteAppointment(AppointmentDeleteRequestDto request) {
        //        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        //        AppointmentDetailResponseDto result;
        appointmentService.deleteAppointment(request);
    }

    @Operation(summary = "서명 완료 처리", description = "예약 아이디로 서명데이터를 생성합니다.")
    @PutMapping("/sign")
    public void insertAppointmentSign(AppointmentSignInsertRequestDto request) {
        appointmentService.insertAppointmentSign(request);
    }

}