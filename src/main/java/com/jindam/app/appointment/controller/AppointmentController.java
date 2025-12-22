package com.jindam.app.appointment.controller;

import com.jindam.app.appointment.model.AppointmentDetailRequestDto;
import com.jindam.app.appointment.model.AppointmentDetailResponseDto;
import com.jindam.app.appointment.service.AppointmentService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "배너 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/banner")
@Slf4j
public class AppointmentController extends MasterController {

    private final AppointmentService appointmentService;

    @Operation(summary = "배너 목록 상세 조회", description = "파라미터 뭔지 모르겠음")
    @GetMapping("")
    public ApiResultDto<AppointmentDetailResponseDto> selectOneUserByUid(AppointmentDetailRequestDto request) {
        ApiResultDto<AppointmentDetailResponseDto> apiResultVo = new ApiResultDto<>();
        AppointmentDetailResponseDto result;

        result = appointmentService.selectBanner(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }
    //
    //    @Operation(summary = "사용자 정보 생성", description = "사용자 정보를 입력합니다.")
    //    @PostMapping("")
    //    public ApiResultDto<UserDetailResponseDto> insertOneUser(UserInsertRequestDto request) {
    //        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
    //        UserDetailResponseDto result;
    //
    //        result = userService.insertUser(request);
    //        apiResultVo.setData(result);
    //
    //        return apiResultVo;
    //    }
    //
    //    @Operation(summary = "사용자 정보 수정", description = "사용자 상세정보를 수정합니다.")
    //    @PutMapping("")
    //    public ApiResultDto<UserDetailResponseDto> updateUserByUid(UserUpdateRequestDto request) {
    //        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
    //        UserDetailResponseDto result;
    //
    //        result = userService.updateUser(request);
    //        apiResultVo.setData(result);
    //
    //        return apiResultVo;
    //    }
    //
    //    @Operation(summary = "사용자 정보 수정", description = "사용자 상세정보를 삭제 처리합니다.")
    //    @DeleteMapping("")
    //    public ApiResultDto<UserDetailResponseDto> deleteUserByUid(UserDeleteRequestDto request) {
    //        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
    //        UserDetailResponseDto result;
    //
    //        result = userService.deleteUser(request);
    //        apiResultVo.setData(result);
    //
    //        return apiResultVo;
    //    }
    //
    //    @Operation(summary = "사용자 로그인 처리", description = "사용자 상세정보를 조회 후 최종 로그인 일시 업데이트")
    //    @GetMapping("/login")
    //    public ApiResultDto<UserDetailResponseDto> loginUserByUid(UserDetailRequestDto request) {
    //        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
    //        UserDetailResponseDto result;
    //
    //        result = userService.loginUser(request);
    //        apiResultVo.setData(result);
    //
    //        return apiResultVo;
    //
    //    }
}
