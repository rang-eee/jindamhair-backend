package com.jindam.app.file.model;

import java.time.LocalDateTime;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "파일 상세 응답 모델")
public class FileDetailResponseDto {

	@Schema(description = "파일 ID")
	private String fileId;

	@Schema(description = "정렬 순서")
	private Integer sortOrder;

	@Schema(description = "파일 유형 코드")
	private String fileTypeCode;

	@Schema(description = "원본 파일 명")
	private String orgFileName;

	@Schema(description = "변환 파일 명")
	private String convertFileName;

	@Schema(description = "파일 경로")
	private String filePath;

	@Schema(description = "파일 크기")
	private String fileSize;

	@Schema(description = "생성 일시")
	private LocalDateTime createAt;

	@Schema(description = "생성 ID")
	private String createId;
}
