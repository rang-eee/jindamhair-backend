package com.jindam.app.notification.contoller;

import com.jindam.app.appointment.model.AppointmentDetailRequestDto;
import com.jindam.app.appointment.model.AppointmentDetailResponseDto;
import com.jindam.app.notification.service.NotificationService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Tag(name = "알림 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/notification")
@Slf4j
public class NotificationContorller extends MasterController {

    private final NotificationService notificationService;

    @Operation(summary = "알림 조회", description = "알림데이터 조회합니다.")
    @GetMapping("")
    public ApiResultDto<AppointmentDetailResponseDto> selectNotification(AppointmentDetailRequestDto request) {
        //        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        //        AppointmentDetailResponseDto result;
        //        result = appointmentService.selectAppointmentById(request);
        //        apiResultVo.setData(result);

        return null;

    }

    @Operation(summary = "알림 생성", description = "알림데이터 생성합니다.")
    @PostMapping("")
    public ApiResultDto<AppointmentDetailResponseDto> insertNotification(AppointmentDetailRequestDto request) {
        return null;
    }

    @Operation(summary = "알림 수정", description = "알림데이터 수정합니다.")
    @PatchMapping("")
    public ApiResultDto<AppointmentDetailResponseDto> updateNotification(AppointmentDetailRequestDto request) {
        return null;
    }

    @Operation(summary = "알림 삭제", description = "알림데이터 삭제처리합니다.")
    @DeleteMapping("")
    public ApiResultDto<AppointmentDetailResponseDto> deleteNotification(AppointmentDetailRequestDto request) {
        return null;
    }

}
