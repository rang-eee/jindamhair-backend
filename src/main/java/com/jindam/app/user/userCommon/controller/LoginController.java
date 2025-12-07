package com.jindam.app.user.userCommon.controller;

import com.jindam.app.user.userCommon.model.UserDetailRequestDto;
import com.jindam.app.user.userCommon.model.UserDetailResponseDto;
import com.jindam.app.user.userCommon.service.LoginService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Login api")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/login")
@Slf4j
public class LoginController extends MasterController {

    private final LoginService loginService;

    @Operation(summary = "사용자 로그인 처리", description = "사용자 상세정보를 조회 후 최종 로그인 일시 업데이트")
    @GetMapping("")
    public ApiResultDto<UserDetailResponseDto> loginUserByUid(UserDetailRequestDto request) {
        ApiResultDto<UserDetailResponseDto> apiResultVo = new ApiResultDto<>();
        UserDetailResponseDto result;

        result = loginService.loginUser(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }

}
