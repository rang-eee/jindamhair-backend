package com.jindam.app.example.contoller;

import java.io.IOException;
import java.util.List;

import org.apache.commons.lang3.ObjectUtils;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.jindam.app.example.model.ExampleDetailResponseDto;
import com.jindam.app.example.model.ExampleDownloadRequestDto;
import com.jindam.app.example.model.ExampleExcelUploadRequestDto;
import com.jindam.app.example.model.ExampleListRequestDto;
import com.jindam.app.example.model.ExampleListResponseDto;
import com.jindam.app.example.model.ExampleModifyRequestDto;
import com.jindam.app.example.model.ExampleRegisterRequestDto;
import com.jindam.app.example.service.ExampleService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;
import com.jindam.base.dto.ResourceDto;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Tag(name = "00000. [공통] 예제 관련 처리")
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
    @ApiOperation(value = "전체 목록 조회", notes = "기본적으로 모든 예제 항목을 조회하며, 선택적으로 검색 조건을 바탕으로 예제 항목을 조회합니다.")
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

    @ApiOperation(value = "단일 항목 세부 조회", notes = "특정 예제 항목을 ID로 조회합니다.")
    @GetMapping("/{userId}")
    public ApiResultDto<ExampleDetailResponseDto> getExampleById(@ApiParam(value = "유저 아이디", example = "1") @PathVariable String userId) {

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

    @ApiOperation(value = "새로운 예제 항목 생성", notes = "새로운 예제 항목을 생성합니다.")
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

    @ApiOperation(value = "기존 예제 항목 수정", notes = "특정 ID의 예제 항목을 수정합니다.")
    @PutMapping("/{userId}")
    public ApiResultDto<ExampleDetailResponseDto> updateExample(@ApiParam(value = "유저 아이디", example = "1") @PathVariable String userId, @RequestBody ExampleModifyRequestDto request) {

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

    @ApiOperation(value = "기존 예제 항목 삭제", notes = "특정 ID의 예제 항목을 삭제합니다.")
    @DeleteMapping("/{userId}")
    public ApiResultDto<Boolean> deleteExample(@ApiParam(value = "유저 아이디", example = "1") @PathVariable String userId) {

        ApiResultDto<Boolean> apiResultVo = new ApiResultDto<>(); // API 응답 객체

        // 기존 항목 존재 여부 확인 및 삭제
        boolean deleted = exampleService.delete(userId);

        apiResultVo.setResultCode(200);
        apiResultVo.setResultMessage("common.proc.success.delete");
        apiResultVo.setData(deleted);

        return apiResultVo; // 최종 API 응답 반환

    }

    /**
     * 전체 목록 조회 API (intf)
     *
     * 기본적으로 모든 예제 항목을 조회하며, 선택적으로 검색 키워드와 검색 유형을 통해 필터링할 수 있습니다.
     *
     * @param searchKeyword 검색 키워드 (선택적)
     * @param searchType 검색 유형 (default: userName)
     * @return ApiResultVo<List<ExampleDetailResponseDto>> 예제 항목 목록을 포함하는 API 응답 객체
     */
    @ApiOperation(value = "전체 목록 TB_OHHR01 조회 테스트 (intf)", notes = "intf.TB_OHHR01")
    @GetMapping("/intf/list")
    public ApiResultDto<List<ExampleDetailResponseDto>> getExamplesByCriteriaForIntf() {

        ApiResultDto<List<ExampleDetailResponseDto>> apiResultVo = new ApiResultDto<>(); // API 응답 객체
        List<ExampleDetailResponseDto> result; // 조회 결과

        // 기본 성공 메시지 설정
        apiResultVo.setResultCode(200);
        apiResultVo.setResultMessage("common.proc.success.search");

        // 검색 조건을 포함하는 요청 객체 생성
        ExampleListRequestDto request = ExampleListRequestDto.builder()
            .build();

        // 서비스 호출을 통해 조회 결과 얻기
        result = exampleService.findByCriteriaForIntf(request);

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
     * 메일 발송 예제
     *
     * 특정 사용자들에게 메일을 발송하는 테스트를 수행합니다.<br/>
     * 요청 본문에 포함된 사용자 ID 목록을 기반으로 메일이 전송됩니다.
     *
     * @param userIds 메일 발송 대상 사용자의 ID 목록
     */
    @PostMapping("/mail")
    @ApiOperation(value = "메일 발송 예제", notes = "특정 사용자에게 메일 발송을 테스트합니다.")
    public void sendEmail(@RequestBody List<String> emails) {
        exampleService.sendEmail(emails);
    }

    /**
     * 엑셀 업로드 예제
     *
     * 엑셀을 업로드하여 형식에 맞게 데이터를 저장하는 테스트를 수행합니다.<br/>
     *
     * @param reportRequestVo 제보 등록 정보
     * @param files 첨부 파일 리스트
     * @return ApiResultVo<Boolean> true:처리 성공, false:실패
     */
    @PostMapping(value = "/excel", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ApiOperation(value = "엑셀 업로드 예제", notes = "엑셀을 업로드하여 형식에 맞게 데이터를 저장합니다.")
    public void uploadExcel(//
            @ModelAttribute(value = "request") ExampleExcelUploadRequestDto request, //
            @RequestPart(value = "file") @ApiParam(name = "file", value = "첨부파일") MultipartFile file //
    ) {
        exampleService.uploadExcel(request, file);
    }

    /**
     * 정적 파일 다운로드 예제
     *
     * 정적 을 다운로드 또는 미리보기하는 테스트를 수행합니다.<br/>
     *
     * @return ResponseEntity<Resource> 정적 양식 파일 리소스
     */
    @ApiOperation(value = "정적 파일 다운로드 및 미리보기 예제", notes = "정적 파일 다운로드 또는 미리보기합니다.")
    @PostMapping("/exceldownload")
    public ResponseEntity<Resource> excelDownloadCompanyList( //
            @Valid @RequestBody ExampleDownloadRequestDto request, //
            @AccountPrincipal AccountPrincipalDto user //
    ) throws IOException {
        ResourceDto resource = exampleService.downloadExcelTemplate(request);

        if (resource == null)
            throw new ExcelException(ExcelException.Reason.INVALID_RESOURCE);

        return responseResource(resource);
    }

    /**
     * 정적 파일 다운로드 예제
     *
     * 정적 을 다운로드 또는 미리보기하는 테스트를 수행합니다.<br/>
     *
     * @return ResponseEntity<Resource> 정적 양식 파일 리소스
     */
    @ApiOperation(value = "S3 이미지 미리보기")
    @GetMapping("/preview")
    public ResponseEntity<Resource> preview(@AccountPrincipal AccountPrincipalDto user, @ApiParam(value = "미리보기 여부", example = "true") Boolean isPreview) throws IOException {
        Resource resource = new UrlResource("https://d1oyf0frugj3qi.cloudfront.net/dev_tqms/2025/01/20973/source.jpg?null");

        return responseResource(ResourceDto.builder()
            .resource(resource)
            .downloadFileName("download")
            .mediaType(MediaType.IMAGE_JPEG)
            .preview(isPreview)
            .build());
    }

    /**
     * Open API 조회 API
     */
    @ApiOperation(value = "Open API 조회", notes = "Open API 조회 예제입니다.")
    @GetMapping("/openapi")
    public ApiResultDto<ExampleOpenapiResponseDto> getOpenApiData(ExampleOpenapiRequestDto request) throws IOException {
        ApiResultDto<ExampleOpenapiResponseDto> apiResultVo = new ApiResultDto<>(); // API 응답 객체

        ExampleOpenapiResponseDto result = new ExampleOpenapiResponseDto(); // 조회 결과

        // 기본 성공 메시지 설정
        apiResultVo.setResultMessage("common.proc.success.search");

        // 서비스 호출을 통해 조회 결과 얻기
        result = exampleService.findOpenapi(request);

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
     * 트랜잭션 테스트 API
     */
    @ApiOperation(value = "트랜잭션 테스트", notes = "트랜잭션 테스트입니다.")
    @PostMapping("/transaction")
    public ApiResultDto<ExampleOpenapiResponseDto> saveTransactionTest(//
            @RequestBody ExampleRegisterRequestDto request//
    ) throws IOException {
        ApiResultDto<ExampleOpenapiResponseDto> apiResultVo = new ApiResultDto<>(); // API 응답 객체

        exampleService.saveTransactionTest(request);

        return apiResultVo; // 최종 API 응답 반환
    }
}
