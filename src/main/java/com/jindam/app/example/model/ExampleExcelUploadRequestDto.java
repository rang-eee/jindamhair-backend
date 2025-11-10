package com.jindam.app.example.model;

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
@Schema(description = "업로드 ID 요청")
public class ExampleExcelUploadRequestDto {

    @Schema(description = "업로드 ID", example = "2", required = true)
    private Long uploadId;

}
