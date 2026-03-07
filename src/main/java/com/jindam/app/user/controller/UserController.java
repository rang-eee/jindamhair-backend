package com.jindam.app.user.controller;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jindam.app.user.model.DailyScheduleResponseDto;
import com.jindam.app.user.model.MonthlyScheduleResponseDto;
import com.jindam.app.user.model.ScheduleRequestDto;
import com.jindam.app.user.model.UserDeleteRequestDto;
import com.jindam.app.user.model.UserDetailRequestDto;
import com.jindam.app.user.model.UserDetailResponseDto;
import com.jindam.app.user.model.UserFavoriteDetailRequestDto;
import com.jindam.app.user.model.UserFavoriteDetailResponseDto;
import com.jindam.app.user.model.UserFavoriteUpdateRequestDto;
import com.jindam.app.user.model.UserInsertRequestDto;
import com.jindam.app.user.model.UserUpdateRequestDto;
import com.jindam.app.user.service.UserService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Tag(name = "사용자 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/user")
@Slf4j
public class UserController extends MasterController {

    private final UserService userService;

    @Operation(summary = "사용자 상세 조회", description = "사용자 상세정보를 조회합니다.")
    @GetMapping("")
    public ApiResultDto<UserDetailResponseDto> selectOneUserByUid(UserDetailRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.selectOneUser(request);

        apiResultVo.setData(result);

        return apiResultVo;

    }

    @Operation(summary = "사용자 정보 생성", description = "사용자 정보를 입력합니다.")
    @PostMapping("")
    public ApiResultDto<UserDetailResponseDto> insertOneUser(@RequestBody UserInsertRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.insertUser(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "사용자 정보 수정", description = "사용자 상세정보를 수정합니다")
    @PatchMapping("")
    public ApiResultDto<UserDetailResponseDto> updateUserByUid(@RequestBody UserUpdateRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.updateUser(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "디자이너 프로필 수정 처리", description = "디자이너 프로필을 수정합니다. (빈값은 null로 들어갑니다.)")
    @PutMapping("/designer/profile")
    public ApiResultDto<UserDetailResponseDto> updateDesignerProfile(@RequestBody UserUpdateRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.updateDesignerProfile(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "회원 탈퇴 처리", description = "회원 탈퇴: 유저 + 예약 + 알림 + 매장 일괄 삭제 처리")
    @DeleteMapping("")
    public ApiResultDto<Void> deleteUserByUid(UserDeleteRequestDto request) {
        ApiResultDto<Void> apiResultVo = new ApiResultDto<>();

        userService.deleteUser(request);
        // data는 null — 삭제 성공 시 resultCode 200만 반환

        return apiResultVo;
    }

    @Operation(summary = "사용자 로그인 처리", description = "사용자 상세정보를 조회 후 최종 로그인 일시 업데이트")
    @GetMapping("/login")
    public ApiResultDto<UserDetailResponseDto> loginUserByUid(UserDetailRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.loginUser(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }

    @Operation(summary = "디자이너 목록 조회", description = "디자이너 상세정보를 조회(페이징)")
    @GetMapping("/desinger-page")
    public ApiResultDto<PagingResponseDto<UserDetailResponseDto>> selectListDesignerPaging(UserDetailRequestDto request) {
        ApiResultDto<PagingResponseDto<UserDetailResponseDto>> apiResultVo = new ApiResultDto<>();
        PagingResponseDto<UserDetailResponseDto> result;

        result = userService.selectListDesignerPaging(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "유저 즐겨찾기 목록 조회", description = "페이징을 지원합니다.")
    @GetMapping("/favorite")
    public ApiResultDto<PagingResponseDto<UserFavoriteDetailResponseDto>> selectAppointmentByCustId(UserFavoriteDetailRequestDto request) {
        ApiResultDto<PagingResponseDto<UserFavoriteDetailResponseDto>> apiResultVo = new ApiResultDto<>();
        PagingResponseDto<UserFavoriteDetailResponseDto> result;
        result = userService.selectUserFavoriteByUidPaging(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "유저 즐겨찾기 변경 요청", description = "유저 즐겨찾기 추가 및 취소 합니다.")
    @PatchMapping("/favorite")
    public ApiResultDto<Object> updateFavoriteUser(@RequestBody UserFavoriteUpdateRequestDto request) {
        userService.updateFavoriteUser(request);
        return new ApiResultDto<>();
    }

    @Operation(summary = "디자이너 월별 일정 목록조회", description = "년월,UID를 입력하면 한달 일정을 조회합니다.")
    @GetMapping("/mothlySchedule")
    public List<MonthlyScheduleResponseDto> selectMonthlySchedule(ScheduleRequestDto request) {
        List<MonthlyScheduleResponseDto> result;
        result = userService.selectMonthlySchedule(request);
        return result;
    }

    @Operation(summary = "디자이너 일별 일정 목록조회", description = "년월일,UID를 입력 일별 일정을 조회합니다.")
    @GetMapping("/dailySchedule")
    public List<DailyScheduleResponseDto> selectDailySchedule(ScheduleRequestDto request) {
        List<DailyScheduleResponseDto> result;
        result = userService.selectDailySchedule(request);
        return result;
    }
}
