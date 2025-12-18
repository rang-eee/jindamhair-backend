package com.jindam.app.shop.controller;

import com.jindam.app.shop.model.*;
import com.jindam.app.shop.service.ShopService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "헤어샵 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/shop")
@Slf4j
public class ShopController extends MasterController {

    private final ShopService shopService;

    /**
     * 전체 목록 조회 API
     *
     * @return ApiResultVo<List<ExampleDetailResponseDto>>
     */
    @Operation(//
            summary = "전체 헤어샵 목록 조회", //
            description = "헤어샵 목록을 조회합니다.")
    @GetMapping("")
    public ApiResultDto<List<ShopDetailResponseDto>> selectListShop() {

        ApiResultDto<List<ShopDetailResponseDto>> apiResultVo = new ApiResultDto<>(); // API 응답 객체
        List<ShopDetailResponseDto> result; // 조회 결과

        // 서비스 호출을 통해 조회 결과 얻기
        result = shopService.selectListShop();

        // 조회 결과가 비어있는 경우 실패 메시지 설정
        if (ObjectUtils.isEmpty(result)) {
            apiResultVo.setData(null);
            apiResultVo.setResultMessage("common.proc.failed.search.empty");
        } else {
            // 조회 결과가 있는 경우에만 데이터 설정
            apiResultVo.setData(result);
        }

        return apiResultVo; // 최종 API 응답 반환
    }

    @Operation(//
            summary = "추가 헤어샵 매장 입력", //
            description = "디자이너 헤어샵 테이블에 정보를 입력합니다.")
    @PostMapping("")
    public ApiResultDto<List<DesingerShopDetailResponseDto>> insertListShop(@RequestBody List<DesignerShopInsertRequestDto> request) {

        ApiResultDto<List<DesingerShopDetailResponseDto>> apiResultVo = new ApiResultDto<>(); // API 응답 객체
        List<DesingerShopDetailResponseDto> result; //인서트 결과값

        result = shopService.insertListShop(request);

        if (ObjectUtils.isEmpty(result)) {
            apiResultVo.setData(null);
            apiResultVo.setResultMessage("error");
        } else {
            apiResultVo.setData(result);
        }

        return apiResultVo; // 최종 API 응답 반환
    }

    @Operation(//
            summary = "디자이너 헤어샵 수정", //
            description = "uid의 해당하는 디자이너 헤어샵 수정 요청")
    @PatchMapping("")
    public ApiResultDto<List<DesingerShopDetailResponseDto>> updateListShop(@RequestBody List<DesignerShopUpdateRequestDto> request) {

        ApiResultDto<List<DesingerShopDetailResponseDto>> apiResultVo = new ApiResultDto<>(); // API 응답 객체
        List<DesingerShopDetailResponseDto> result;
        // 기존 항목 존재 여부 확인 및 삭제
        result = shopService.updateListShop(request);

        if (ObjectUtils.isEmpty(result)) {
            apiResultVo.setData(null);
            apiResultVo.setResultMessage("error");
        } else {
            apiResultVo.setData(result);
        }

        return apiResultVo; // 최종 API 응답 반환

    }

    @Operation(//
            summary = "디자이너 헤어샵 삭제", //
            description = "uid의 해당하는 디자이너 헤어샵 삭제 요청")
    @DeleteMapping("")
    public ApiResultDto<List<DesingerShopDetailResponseDto>> deleteListShop(@RequestBody List<DesingerShopDeleteRequestDto> request) {

        ApiResultDto<List<DesingerShopDetailResponseDto>> apiResultVo = new ApiResultDto<>(); // API 응답 객체
        List<DesingerShopDetailResponseDto> result;
        // 기존 항목 존재 여부 확인 및 삭제
        result = shopService.deleteListShop(request);

        if (ObjectUtils.isEmpty(result)) {
            apiResultVo.setData(null);
            apiResultVo.setResultMessage("error");
        } else {
            apiResultVo.setData(result);
        }

        return apiResultVo; // 최종 API 응답 반환

    }

}
