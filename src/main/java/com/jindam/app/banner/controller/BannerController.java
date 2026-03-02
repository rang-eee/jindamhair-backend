package com.jindam.app.banner.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jindam.app.banner.model.BannerDetailRequestDto;
import com.jindam.app.banner.model.BannerDetailResponseDto;
import com.jindam.app.banner.service.BannerService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Tag(name = "배너 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/banner")
@Slf4j
public class BannerController extends MasterController {

    private final BannerService bannerService;

    @Operation(summary = "배너 목록 상세 조회", description = "위치에 따른 배너 목록을 조회합니다.")
    @GetMapping("")
    public ApiResultDto<List<BannerDetailResponseDto>> selectListBanner(BannerDetailRequestDto request) {
        ApiResultDto<List<BannerDetailResponseDto>> apiResultVo = new ApiResultDto<>();
        List<BannerDetailResponseDto> result;

        result = bannerService.selectListBanner(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }
}
