package com.jindam.app.notification.model;

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
@Schema(description = " 응답 모델")
public class NotificationDetailResponseDto {
    @Schema(description = "알림 ID", example = "123")
    private String notificationId;

    @Schema(description = "수신자 사용자ID", example = "123")
    private String receiverUid;

    @Schema(description = "알림 제목", example = "123")
    private String notificationTitle;

    @Schema(description = "알림 내용", example = "123")
    private String notificationContent;

    @Schema(description = "알림 토픽", example = "123")
    private String notificationTopic;

    @Schema(description = "이벤트 클릭", example = "123")
    private String eventClick;

    @Schema(description = "생성 일시", example = "123")
    private LocalDateTime createAt;

    @Schema(description = "생성 ID", example = "123")
    private String createId;

    @Schema(description = "수정 일시", example = "123")
    private LocalDateTime updateAt;

    @Schema(description = "수정 ID", example = "123")
    private String updateId;

    @Schema(description = "삭제 여부", example = "Y")
    private String deleteYn;

    @Schema(description = "삭제 일시", example = "123")
    private LocalDateTime deleteAt;

    @Schema(description = "삭제 ID", example = "123")
    private String deleteId;
}

