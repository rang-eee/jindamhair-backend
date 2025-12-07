package com.jindam.app.user.userCommon.model;

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
@Schema(description = "사용자 상세 조회 요청 모델")
public class UserDetailRequestDto {

    @Schema(description = "유저 아이디", example = "KShJUkrtJrVdRKNXCNz4BT8oRyn1")
    private String uid;

}
