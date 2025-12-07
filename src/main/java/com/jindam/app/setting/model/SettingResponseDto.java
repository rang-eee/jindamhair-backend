package com.jindam.app.setting.model;

import com.jindam.base.dto.PagingRequestDto;
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
@Schema(description = "SettingResponseDto")
public class SettingResponseDto extends PagingRequestDto {

    @Schema(description = "aos 최종 버전")
    private String aosLastVer;

    @Schema(description = "aos 허용 최소 빌드 번호")
    private String aosPermissionMinimumBuildNumber;

    @Schema(description = "ios 최종 버전")
    private String iosLastVer;

    @Schema(description = "ios 허용 최소 빌드 번호")
    private String iosPermissionMinimumBuildNumber;

    @Schema(description = "생성 일시")
    private LocalDateTime createAt;

    @Schema(description = "생성자 ID")
    private String createId;

    @Schema(description = "수정 일시")
    private LocalDateTime updateAt;

    @Schema(description = "수정자 ID")
    private String updateId;

    @Schema(description = "삭제여부")
    private String deleteYn;

    @Schema(description = "삭제자 ID")
    private String deleteId;

    @Schema(description = "삭제 일시")
    private LocalDateTime deleteAt;

}