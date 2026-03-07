package com.jindam.app.notification.contoller;

import com.jindam.app.notification.model.*;
import com.jindam.app.notification.service.NotificationService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "알림 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/notification")
@Slf4j
public class NotificationContorller extends MasterController {

    private final NotificationService notificationService;

    // ───────────── 알림 (푸시 트리거) ─────────────

    @Operation(summary = "알림(푸시) 생성", description = "알림 데이터를 생성합니다.")
    @PostMapping("")
    public ApiResultDto<Object> insertNotification(@RequestBody NotificationInsertRequestDto request) {
        ApiResultDto<Object> apiResultVo = new ApiResultDto<>();
        notificationService.insertNotification(request);
        apiResultVo.setResultCode(200);
        return apiResultVo;
    }

    // ───────────── 알림 센터 ─────────────

    @Operation(summary = "알림 센터 목록 조회", description = "수신자 uid로 조회합니다.")
    @GetMapping("/center")
    public ApiResultDto<List<NotificationCenterDetailResponseDto>> selectNotificationCenterList(NotificationCenterDetailRequestDto request) {
        ApiResultDto<List<NotificationCenterDetailResponseDto>> apiResultVo = new ApiResultDto<>();
        List<NotificationCenterDetailResponseDto> result = notificationService.selectNotificationCenterListByUid(request);
        apiResultVo.setData(result);
        apiResultVo.setResultCode(200);
        return apiResultVo;
    }

    @Operation(summary = "알림 센터 등록", description = "알림 센터 데이터를 생성합니다.")
    @PostMapping("/center")
    public ApiResultDto<Object> insertNotificationCenter(@RequestBody NotificationInsertCenterRequestDto request) {
        ApiResultDto<Object> apiResultVo = new ApiResultDto<>();
        notificationService.insertNotificationCenter(request);
        apiResultVo.setResultCode(200);
        return apiResultVo;
    }

    @Operation(summary = "알림 센터 읽음 처리", description = "알림 센터 데이터를 수정합니다.")
    @PatchMapping("/center")
    public ApiResultDto<Object> updateNotificationCenter(@RequestBody NotificationCenterDetailRequestDto request) {
        ApiResultDto<Object> apiResultVo = new ApiResultDto<>();
        notificationService.updateNotificationCenter(request);
        apiResultVo.setResultCode(200);
        return apiResultVo;
    }

    @Operation(summary = "알림 센터 삭제", description = "알림 센터 데이터를 삭제처리합니다.")
    @DeleteMapping("/center")
    public ApiResultDto<Object> deleteNotificationCenter(NotificationCenterDetailRequestDto request) {
        ApiResultDto<Object> apiResultVo = new ApiResultDto<>();
        notificationService.deleteNotificationCenter(request);
        apiResultVo.setResultCode(200);
        return apiResultVo;
    }

}
