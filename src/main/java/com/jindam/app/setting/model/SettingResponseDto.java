package com.jindam.app.setting.model;

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
@Schema(description = "설정 요청 모델")
public class SettingResponseDto {

    @Schema(description = "AOS 최종 버젼", example = "123")
    private String aosLastVer;

    @Schema(description = "AOS 허용 최소 빌드 번호", example = "123")
    private String aosPermissionMinimumBuildNumber;

    @Schema(description = "IOS 최종 버젼", example = "123")
    private String iosLastVer;

    @Schema(description = "IOS 허용 최소 빌드 번호", example = "123")
    private String iosPermissionMinimumBuildNumber;

    @Schema(description = "생성 일시", example = "123")
    private LocalDateTime createAt;

    @Schema(description = "생성 ID", example = "123")
    private String createId;

    @Schema(description = "수정 일시", example = "123")
    private LocalDateTime updateAt;

    @Schema(description = "수정 ID", example = "123")
    private String updateId;

    @Schema(description = "삭제 여부", example = "y")
    private String deleteYn;

    @Schema(description = "삭제 ID", example = "123")
    private String deleteId;

    @Schema(description = "삭제 일시", example = "123")
    private LocalDateTime deleteAt;

}
