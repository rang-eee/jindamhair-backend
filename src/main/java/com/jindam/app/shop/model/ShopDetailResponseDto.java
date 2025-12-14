package com.jindam.app.shop.model;

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
@Schema(description = "헤어샵 상세 조회 모델")
public class ShopDetailResponseDto {
    @Schema(description = "헤어샵 ID", example = "123")
    private String shopId;

    @Schema(description = "헤어샵 명", example = "123")
    private String shopName;

    @Schema(description = "헤어샵 설명", example = "123")
    private String shopDescription;

    @Schema(description = "헤어샵 주소", example = "123")
    private String shopAddr;

    @Schema(description = "헤어샵 주소 상세", example = "123")
    private String shopAddrDetail;

    @Schema(description = "헤어샵 연락처", example = "123")
    private String shopContact;

    @Schema(description = "위치 경도", example = "123")
    private String positionLngt;

    @Schema(description = "위치 위도", example = "123")
    private String positionLatt;

    @Schema(description = "우편번호", example = "123")
    private String zipcode;

    @Schema(description = "사용 여부", example = "123")
    private String useYn;

    @Schema(description = "생성 일시", example = "123")
    private LocalDateTime createAt;

    @Schema(description = "생성 ID", example = "123")
    private String createId;

    @Schema(description = "수정 일시", example = "123")
    private LocalDateTime updateAt;

    @Schema(description = "수정 ID", example = "123")
    private String updateId;

    @Schema(description = "삭제 여부", example = "123")
    private String deleteYn;

    @Schema(description = "삭제 일시", example = "123")
    private LocalDateTime deleteAt;

    @Schema(description = "삭제 ID", example = "123")
    private String deleteId;
}
