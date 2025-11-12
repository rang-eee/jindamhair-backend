package com.jindam.app.example.contoller;

import java.util.List;

import org.apache.commons.lang3.ObjectUtils;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jindam.app.example.model.ExampleDetailResponseDto;
import com.jindam.app.example.model.ExampleListRequestDto;
import com.jindam.app.example.model.ExampleListResponseDto;
import com.jindam.app.example.model.ExampleModifyRequestDto;
import com.jindam.app.example.model.ExampleRegisterRequestDto;
import com.jindam.app.example.service.ExampleService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Tag(name = "000. [공통] 예제 관련 처리")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/v1/api/example")
@Slf4j
public class ExampleController extends MasterController {

    private final ExampleService exampleService;

    /**
     * 전체 목록 페이징 조회 API
     *
     * 기본적으로 페이지 데이터 예제 항목을 조회하며, 선택적으로 검색 키워드와 검색 유형을 통해 필터링할 수 있습니다.
     *
     * @param searchKeyword 검색 키워드 (선택적)
     * @param searchType 검색 유형 (default: userName)
     * @return ApiResultVo<List<ExampleListResponseDto>> 예제 항목 목록을 포함하는 API 응답 객체
     */
    @Operation(//
            summary = "전체 목록 페이징 조회", //
            description = "기본적으로 페이지 데이터 예제 항목을 조회하며, 선택적으로 검색 조건을 바탕으로 예제 항목을 조회합니다.")
    @GetMapping("/list-page")
    public ApiResultDto<PagingResponseDto<ExampleListResponseDto>> getExamplesByCriteriaPaging(ExampleListRequestDto request) {
        ApiResultDto<PagingResponseDto<ExampleListResponseDto>> apiResultVo = new ApiResultDto<>(); // API 응답 객체

        PagingResponseDto<ExampleListResponseDto> result; // 조회 결과

        // 기본 성공 메시지 설정
        apiResultVo.setResultCode(200);
        apiResultVo.setResultMessage("common.proc.success.search");

        // 서비스 호출을 통해 조회 결과 얻기
        result = exampleService.findByCriteriaPaging(request);

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

    /**
     * 전체 목록 조회 API
     *
     * 기본적으로 모든 예제 항목을 조회하며, 선택적으로 검색 키워드와 검색 유형을 통해 필터링할 수 있습니다.
     *
     * @param searchKeyword 검색 키워드 (선택적)
     * @param searchType 검색 유형 (default: userName)
     * @return ApiResultVo<List<ExampleDetailResponseDto>> 예제 항목 목록을 포함하는 API 응답 객체
     */
    @Operation(//
            summary = "전체 목록 조회", //
            description = "기본적으로 모든 예제 항목을 조회하며, 선택적으로 검색 조건을 바탕으로 예제 항목을 조회합니다.")
    @GetMapping("/list")
    public ApiResultDto<List<ExampleDetailResponseDto>> getExamplesByCriteria(ExampleListRequestDto request) {

        ApiResultDto<List<ExampleDetailResponseDto>> apiResultVo = new ApiResultDto<>(); // API 응답 객체
        List<ExampleDetailResponseDto> result; // 조회 결과

        // 기본 성공 메시지 설정
        apiResultVo.setResultCode(200);
        apiResultVo.setResultMessage("common.proc.success.search");

        // 서비스 호출을 통해 조회 결과 얻기
        result = exampleService.findByCriteria(request);

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
            summary = "단일 항목 세부 조회", //
            description = "특정 예제 항목을 ID로 조회합니다.")
    @GetMapping("/{userId}")
    public ApiResultDto<ExampleDetailResponseDto> getExampleById(@Parameter(description = "유저 아이디", example = "1") @PathVariable String userId) {

        ApiResultDto<ExampleDetailResponseDto> apiResultVo = new ApiResultDto<>(); // API 응답 객체
        ExampleDetailResponseDto result; // 조회 결과

        // 기본 성공 메시지 설정
        apiResultVo.setResultCode(200);
        apiResultVo.setResultMessage("common.proc.success.search");

        // 서비스 호출을 통해 조회 결과 얻기
        result = exampleService.findById(userId);

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
            summary = "새로운 예제 항목 생성", //
            description = "새로운 예제 항목을 생성합니다.")
    @PostMapping("")
    public ApiResultDto<ExampleDetailResponseDto> createExample(@RequestBody ExampleRegisterRequestDto request) {

        ApiResultDto<ExampleDetailResponseDto> apiResultVo = new ApiResultDto<>(); // API 응답 객체

        // 기본 성공 메시지 설정
        apiResultVo.setResultCode(200);
        apiResultVo.setResultMessage("common.proc.success.register");

        // 서비스 호출을 통해 새 항목 생성
        ExampleDetailResponseDto createdExample = exampleService.create(request);

        // 성공적으로 생성한 경우 데이터 설정
        apiResultVo.setData(createdExample);

        return apiResultVo; // 최종 API 응답 반환
    }

    @Operation(//
            summary = "기존 예제 항목 수정", //
            description = "특정 ID의 예제 항목을 수정합니다.")
    @PutMapping("/{userId}")
    public ApiResultDto<ExampleDetailResponseDto> updateExample(@Parameter(description = "유저 아이디", example = "1") @PathVariable String userId, @RequestBody ExampleModifyRequestDto request) {

        ApiResultDto<ExampleDetailResponseDto> apiResultVo = new ApiResultDto<>(); // API 응답 객체

        // 기존 항목 존재 여부 확인 및 수정
        request.setUserId(userId);
        ExampleDetailResponseDto updatedExample = exampleService.update(request);

        // 수정 성공 시 성공 메시지와 데이터 설정
        apiResultVo.setResultCode(200); // 성공 코드
        apiResultVo.setResultMessage("common.proc.success.update");
        apiResultVo.setData(updatedExample);

        return apiResultVo; // 최종 API 응답 반환
    }

    @Operation(//
            summary = "기존 예제 항목 삭제", //
            description = "특정 ID의 예제 항목을 삭제합니다.")
    @DeleteMapping("/{userId}")
    public ApiResultDto<Boolean> deleteExample(@Parameter(description = "유저 아이디", example = "1") @PathVariable String userId) {

        ApiResultDto<Boolean> apiResultVo = new ApiResultDto<>(); // API 응답 객체

        // 기존 항목 존재 여부 확인 및 삭제
        boolean deleted = exampleService.delete(userId);

        apiResultVo.setResultCode(200);
        apiResultVo.setResultMessage("common.proc.success.delete");
        apiResultVo.setData(deleted);

        return apiResultVo; // 최종 API 응답 반환

    }

}
