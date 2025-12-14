package com.jindam.app.user.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.util.Objects;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "사용자 상세 조회 요청 모델")
public class UserDetailRequestDto {

    @Schema(description = "유저 아이디", example = "KShJUkrtJrVdRKNXCNz4BT8oRyn1")
    private String uid;

    @Schema(description = "유저 아이디", example = "test@email.com")
    private String userEmail;

    @Schema(description = "유저 아이디", example = "test1234")
    private String userJoinTypeCode;

    @Schema(description = "추천 디자이너 이메일", example = "test@email.com")
    private String recommendDesignerEmail;

    /**
     * UserInsertRequestDto를 UserDetailRequestDto로 변환합니다.
     */
    public static UserDetailRequestDto from(UserInsertRequestDto dto) {

        // uid가 null이 아닌지 확인하여 NullPointerException 방지
        Objects.requireNonNull(dto.getUid(), "UserInsertRequestDto의 uid는 null일 수 없습니다.");

        return UserDetailRequestDto.builder()
                .uid(dto.getUid())
                .userEmail(dto.getUserEmail())
                .userJoinTypeCode(dto.getUserJoinTypeCode())
                .build();
    }

    /**
     * UserUpdateRequestDto UserDetailRequestDto로 변환합니다.
     */
    public static UserDetailRequestDto from(UserUpdateRequestDto dto) {

        // uid가 null이 아닌지 확인하여 NullPointerException 방지
        Objects.requireNonNull(dto.getUid(), "UserUpdateRequestDto uid는 null일 수 없습니다.");

        return UserDetailRequestDto.builder()
                .uid(dto.getUid())
                .userEmail(dto.getUserEmail())
                .userJoinTypeCode(dto.getUserJoinTypeCode())
                .build();
    }

    /**
     * UserDeleteRequestDto UserDetailRequestDto로 변환합니다.
     */
    public static UserDetailRequestDto from(UserDeleteRequestDto dto) {

        // uid가 null이 아닌지 확인하여 NullPointerException 방지
        Objects.requireNonNull(dto.getUid(), "UserDeleteRequestDto uid는 null일 수 없습니다.");

        return UserDetailRequestDto.builder()
                .uid(dto.getUid())
                .userEmail(dto.getUserEmail())
                .userJoinTypeCode(dto.getUserJoinTypeCode())
                .build();
    }

}
