package com.jindam.base.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

/**
 * 페이징 처리된 데이터를 Response 하기 위한 Vo 클래스
 */
@Getter
@Setter
@SuperBuilder
@AllArgsConstructor
@NoArgsConstructor
public class PagingRequestBaseDto {

    @Builder.Default
    @Schema(description = "현재 페이지", required = false, example = "0")
    private Integer page = 0;

    @Builder.Default
    @Schema(description = "한 페이지당 표시 갯수", required = false, example = "20")
    private Integer limit = 20;

    @Builder.Default
    @Schema(description = "offset", hidden = true)
    private Integer offset = 0;

    @Builder.Default
    @Schema(description = "searchAll", hidden = true)
    private Boolean searchAll = false; // 엑셀 다운로드 등의 경우 limit, offset 미사용

    @Builder.Default
    @Schema(description = "useSummary", hidden = true)
    private boolean useSummary = false; // 합계 데이터 사용 여부

    /**
     * 페이지 설정 시 offset 자동 계산
     */
    public void setPage(Integer page) {
        this.page = page;
        this.offset = limit * page;
    }
}
