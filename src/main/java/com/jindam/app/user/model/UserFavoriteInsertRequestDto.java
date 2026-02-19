package com.jindam.app.user.model;

import com.jindam.base.code.UserAggCode;
import com.jindam.base.code.UserGenderCode;
import com.jindam.base.code.UserTypeCode;
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
@Schema(description = "사용자 즐겨찾기 생성 요청 모델")
public class UserFavoriteInsertRequestDto {

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

    @Schema(description = "작업 일시", example = "")
    private LocalDateTime workAt;

    @Schema(description = "작업 ID", example = "")
    private String workId;

}
