package com.jindam.app.treatment.controller;

import com.jindam.app.setting.model.SettingResponseDto;
import com.jindam.app.setting.service.SettingService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Setting api")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/configuration")
@Slf4j
public class TreatmentController extends MasterController {

    private final SettingService settingService;

    @Operation(summary = "조회 테스트", description = "앱 빌드 버전 조회")
    @GetMapping("/")
    public ApiResultDto<SettingResponseDto> selectConfiguration() {
        ApiResultDto<SettingResponseDto> apiResultVo = new ApiResultDto<>();
        SettingResponseDto result;

        apiResultVo.setResultCode(200);
        apiResultVo.setResultMessage("common.proc.success.search");

        result = settingService.selectData();

        // 조회 결과가 비어있는 경우 실패 메시지 설정
        if (ObjectUtils.isEmpty(result)) {
            apiResultVo.setData(null);
            apiResultVo.setResultMessage("common.proc.failed.search.empty");
        } else {
            // 조회 결과가 있는 경우에만 데이터 설정
            apiResultVo.setData(result);
        }
        return apiResultVo;

    }
}
