package com.jindam.app.file.controller;

import com.jindam.app.file.model.FileDetailResponseDto;
import com.jindam.app.file.service.FileService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "파일 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/file")
@Slf4j
public class FileController extends MasterController {

	private final FileService fileService;

	@Operation(summary = "파일 목록 조회", description = "파일 ID로 파일 목록을 조회합니다.")
	@GetMapping("")
	public ApiResultDto<List<FileDetailResponseDto>> selectListFile(@Parameter(description = "파일 ID") @RequestParam("fileId") String fileId) {
		ApiResultDto<List<FileDetailResponseDto>> apiResultVo = new ApiResultDto<>();
		List<FileDetailResponseDto> result = fileService.selectListFileByFileId(fileId);
		apiResultVo.setData(result);
		return apiResultVo;
	}
}
