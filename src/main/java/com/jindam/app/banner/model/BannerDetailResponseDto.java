package com.jindam.app.banner.model;

import com.jindam.base.code.*;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "배너 상세 조회 응답 모델")
public class BannerDetailResponseDto {
    @Schema(description = "배너 ID", example = "123")
    private String bannerId;

    @Schema(description = "배너 제목", example = "123")
    private String bannerTitle;

    @Schema(description = "배너 내용", example = "123")
    private String bannerContent;

    @Schema(description = "배너 레이어 높이", example = "123")
    private String bannerLayerHeight;

    @Schema(description = "노출 시작 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime displayStartAt;

    @Schema(description = "노출 종료 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime displayEndAt;

    @Schema(description = "정렬 순서", example = "123")
    private String sortOrder;

    @Schema(description = "배너 유형 코드", example = "123")
    private BannerTypeCode bannerTypeCode;

    @Schema(description = "배너 노출 위치 코드", example = "123")
    private BannerDisplayPositionCode bannerDisplayPositionCode;

    @Schema(description = "배너 노출 대상 코드", example = "123")
    private BannerDisplayTargetCode bannerDisplayTargetCode;

    @Schema(description = "배너 노출 상태 코드", example = "123")
    private BannerDisplayStatusCode bannerDisplayStatusCode;

    @Schema(description = "배너 노출 시간 코드", example = "123")
    private BannerDisplayTimeCode bannerDisplayTimeCode;

    @Schema(description = "배너 아이콘 코드", example = "123")
    private BannerIconCode bannerIconCode;

    @Schema(description = "생성 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime createAt;

    @Schema(description = "생성 ID", example = "123")
    private String createId;

    @Schema(description = "수정 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime updateAt;

    @Schema(description = "수정 ID", example = "123")
    private String updateId;

    @Schema(description = "삭제 여부", example = "N")
    private String deleteYn;

    @Schema(description = "삭제 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime deleteAt;

    @Schema(description = "삭제 ID", example = "123")
    private String deleteId;
}
