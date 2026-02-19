package com.jindam.app.user.controller;

import com.jindam.app.user.model.*;
import com.jindam.app.user.service.UserService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

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
    public ApiResultDto<UserDetailResponseDto> insertOneUser(UserInsertRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.insertUser(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "사용자 정보 수정", description = "사용자 상세정보를 수정합니다")
    @PatchMapping("")
    public ApiResultDto<UserDetailResponseDto> updateUserByUid(UserUpdateRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.updateUser(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "디자이너 프로필 수정 처리", description = "디자이너 프로필을 수정합니다. (빈값은 null로 들어갑니다.)")
    @PutMapping("/designer/profile")
    public ApiResultDto<UserDetailResponseDto> updateDesignerProfile(UserUpdateRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.updateDesignerProfile(request);
        apiResultVo.setData(result);

        return apiResultVo;
    }

    @Operation(summary = "사용자 정보 삭제 처리", description = "사용자 상세정보를 삭제 처리합니다.")
    @DeleteMapping("")
    public ApiResultDto<UserDetailResponseDto> deleteUserByUid(UserDeleteRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = userService.deleteUser(request);
        apiResultVo.setData(result);

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
    public void updateFavoriteUser(UserFavoriteUpdateRequestDto request) {
        userService.updateFavoriteUser(request);
    }
}
