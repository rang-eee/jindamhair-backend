package com.jindam.app.shop.model;

import com.jindam.base.code.ShopRegistTypeCode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.Objects;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "디자이너 헤어샵 상세 조회 모델")
public class DesingerShopDetailResponseDto {
    @Schema(description = "디자이너 헤어샵 ID", example = "123")
    private String designerShopId;

    @Schema(description = "사용자ID", example = "123")
    private String uid;

    @Schema(description = "헤어샵 ID", example = "123")
    private String shopId;

    @Schema(description = "헤어샵 등록 유형 코드", example = "123")
    private ShopRegistTypeCode shopRegistTypeCode;

    @Schema(description = "대표 여부", example = "N")
    private String representativeYn;

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

    @Schema(description = "사용 여부", example = "N")
    private String useYn;

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

    @Schema(description = "헤어샵 ID", example = "123")
    private String shpShopId;

    @Schema(description = "헤어샵 명", example = "123")
    private String shpShopName;

    @Schema(description = "헤어샵 설명", example = "123")
    private String shpShopDescription;

    @Schema(description = "헤어샵 주소", example = "123")
    private String shpShopAddr;

    @Schema(description = "헤어샵 주소 상세", example = "123")
    private String shpShopAddrDetail;

    @Schema(description = "헤어샵 연락처", example = "123")
    private String shpShopContact;

    @Schema(description = "위치 경도", example = "123")
    private String shpPositionLngt;

    @Schema(description = "위치 위도", example = "123")
    private String shpPositionLatt;

    @Schema(description = "우편번호", example = "123")
    private String shpZipcode;

    @Schema(description = "사용 여부", example = "Y")
    private String shpUseYn;

    @Schema(description = "생성 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime shpCreateAt;

    @Schema(description = "생성 ID", example = "123")
    private String shpCreateId;

    @Schema(description = "수정 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime shpUpdateAt;

    @Schema(description = "수정 ID", example = "123")
    private String shpUpdateId;

    @Schema(description = "삭제 여부", example = "N")
    private String shpDeleteYn;

    @Schema(description = "삭제 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime shpDeleteAt;

    @Schema(description = "삭제 ID", example = "123")
    private String shpDeleteId;

    /**
     * DesignerShopInsertRequestDto DesingerShopDetailResponseDto 변환합니다.
     */
    public static DesingerShopDetailResponseDto from(DesignerShopInsertRequestDto dto) {

        // uid가 null이 아닌지 확인하여 NullPointerException 방지
        Objects.requireNonNull(dto.getUid(), "DesignerShopInsertRequestDto uid는 null일 수 없습니다.");

        return DesingerShopDetailResponseDto.builder()
            .designerShopId(dto.getDesignerShopId())
            .uid(dto.getUid())
            .shopId(dto.getShopId())
            .shopRegistTypeCode(dto.getShopRegistTypeCode())
            .representativeYn(dto.getRepresentativeYn())
            .shopName(dto.getShopName())
            .shopDescription(dto.getShopDescription())
            .shopAddr(dto.getShopAddr())
            .shopAddrDetail(dto.getShopAddrDetail())
            .shopContact(dto.getShopContact())
            .positionLngt(dto.getPositionLngt())
            .positionLatt(dto.getPositionLatt())
            .zipcode(dto.getZipcode())
            .useYn(dto.getUseYn())
            .createAt(dto.getCreateAt())
            .createId(dto.getCreateId())
            .build();
    }

    /**
     * DesignerShopInsertRequestDto DesingerShopDetailResponseDto 변환합니다.
     */
    public static DesingerShopDetailResponseDto from(DesignerShopUpdateRequestDto dto) {

        // uid가 null이 아닌지 확인하여 NullPointerException 방지
        Objects.requireNonNull(dto.getUid(), " uid는 null일 수 없습니다.");
        Objects.requireNonNull(dto.getDesignerShopId(), " getDesignerShopId null일 수 없습니다.");

        return DesingerShopDetailResponseDto.builder()
            .designerShopId(dto.getDesignerShopId())
            .uid(dto.getUid())
            .shopId(dto.getShopId())
            .shopRegistTypeCode(dto.getShopRegistTypeCode())
            .representativeYn(dto.getRepresentativeYn())
            .shopName(dto.getShopName())
            .shopDescription(dto.getShopDescription())
            .shopAddr(dto.getShopAddr())
            .shopAddrDetail(dto.getShopAddrDetail())
            .shopContact(dto.getShopContact())
            .positionLngt(dto.getPositionLngt())
            .positionLatt(dto.getPositionLatt())
            .zipcode(dto.getZipcode())
            .useYn(dto.getUseYn())
            .updateAt(dto.getUpdateAt())
            .updateId(dto.getUpdateId())
            .build();
    }

    /**
     * DesignerShopInsertRequestDto DesingerShopDetailResponseDto 변환합니다.
     */
    public static DesingerShopDetailResponseDto from(DesingerShopDeleteRequestDto dto) {

        // uid가 null이 아닌지 확인하여 NullPointerException 방지
        Objects.requireNonNull(dto.getUid(), " uid는 null일 수 없습니다.");
        Objects.requireNonNull(dto.getDesignerShopId(), " getDesignerShopId null일 수 없습니다.");

        return DesingerShopDetailResponseDto.builder()
            .designerShopId(dto.getDesignerShopId())
            .uid(dto.getUid())
            .shopId(dto.getShopId())
            .shopRegistTypeCode(dto.getShopRegistTypeCode())
            .useYn(dto.getUseYn())
            .deleteAt(dto.getDeleteAt())
            .deleteId(dto.getDeleteId())
            .deleteYn(dto.getDeleteYn())
            .build();
    }
}
