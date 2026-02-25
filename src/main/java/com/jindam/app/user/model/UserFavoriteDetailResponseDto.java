package com.jindam.app.user.model;

import java.time.LocalDateTime;

import com.jindam.base.code.UserAggCode;
import com.jindam.base.code.UserGenderCode;
import com.jindam.base.code.UserTypeCode;

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
@Schema(description = "사용자 즐겨찾기 생성 요청 모델")
public class UserFavoriteDetailResponseDto {

    @Schema(description = "사용자 즐겨찾기 ID", example = "")
    private String userBookmarkId;

    @Schema(description = "사용자ID", example = "")
    private String uid;

    @Schema(description = "즐겨찾기 대상 사용자 ID", example = "")
    private String bookmarkTargetUserId;

    @Schema(description = "사용자 성별 코드", example = "")
    private UserGenderCode userGenderCode;

    @Schema(description = "사용자 연령대 코드", example = "")
    private UserAggCode userAggCode;

    @Schema(description = "사용자 유형 코드", example = "")
    private UserTypeCode userTypeCode;

    @Schema(description = "생성 일시", example = "")
    private LocalDateTime createAt;

    @Schema(description = "생성 ID", example = "")
    private String createId;

    @Schema(description = "수정 일시", example = "")
    private LocalDateTime updateAt;

    @Schema(description = "수정 ID", example = "")
    private String updateId;

    @Schema(description = "삭제 여부", example = "")
    private String deleteYn;

    @Schema(description = "삭제 일시", example = "")
    private LocalDateTime deleteAt;

    @Schema(description = "삭제 ID", example = "")
    private String deleteId;

}
