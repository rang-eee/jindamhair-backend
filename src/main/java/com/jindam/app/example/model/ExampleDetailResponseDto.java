package com.jindam.app.example.model;

import java.time.LocalDateTime;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "예시 상세 응답 모델")
public class ExampleDetailResponseDto {

    @Schema(description = "userId", example = "1")
    private String userId;

    @Schema(description = "userName", example = "홍길동")
    private String userName;

    @Schema(description = "age", example = "25")
    private Integer age;

    @Schema(description = "사용 여부", example = "Y")
    private String useYn;

    @Schema(description = "생성자", example = "1")
    private Long createId;

    @Schema(description = "생성일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime createAt;

    @Schema(description = "업데이트 사용자", example = "1")
    private Long updateId;

    @Schema(description = "업데이트 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime updateAt;

}
