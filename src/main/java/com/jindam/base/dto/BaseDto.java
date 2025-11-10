package com.jindam.base.dto;

import java.time.LocalDateTime;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

/**
 * 기본 컬럼 DTO 클래스
 */
@Getter
@Setter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
public class BaseDto {

    @Schema(description = "사용 여부", example = "Y")
    private String useYn;

    @Schema(description = "생성 ID", example = "1001")
    private Long createId;

    @Schema(description = "생성 사용자 ID", example = "hong")
    private String createUserId;

    @Schema(description = "생성 사용자 명", example = "홍길동")
    private String createUserName;

    @Schema(description = "생성 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime createAt;

    @Schema(description = "수정 ID", example = "2002")
    private Long updateId;

    @Schema(description = "수정 사용자 ID", example = "1909244")
    private String updateUserId;

    @Schema(description = "수정 사용자 명", example = "홍길동")
    private String updateUserName;

    @Schema(description = "수정 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime updateAt;

    @Schema(description = "삭제 ID", example = "2002")
    private Long deleteId;

    @Schema(description = "삭제 사용자 ID", example = "1909244")
    private String deleteUserId;

    @Schema(description = "삭제 사용자 명", example = "홍길동")
    private String deleteUserName;

    @Schema(description = "삭제 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime deleteAt;
}
