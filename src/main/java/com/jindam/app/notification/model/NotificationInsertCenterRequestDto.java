package com.jindam.app.notification.model;

import com.jindam.base.code.NotificationTypeCode;
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
@Schema(description = "알림센터 생성 요청 모델")
public class NotificationInsertCenterRequestDto {
    @Schema(description = "알림 센터 ID", example = "123")
    private String notificationCenterId;

    @Schema(description = "알림 토픽", example = "123")
    private String notificationTopic;

    @Schema(description = "이벤트 클릭", example = "123")
    private String eventClick;

    @Schema(description = "알림 유형 코드", example = "123")
    private NotificationTypeCode notificationTypeCode;

    @Schema(description = "알림 제목", example = "123")
    private String notificationTitle;

    @Schema(description = "알림 내용", example = "123")
    private String notificationContent;

    @Schema(description = "수신자 사용자ID", example = "123")
    private String receiverUid;

    @Schema(description = "예약 ID", example = "123")
    private String appointmentId;

    @Schema(description = "예약 일시", example = "123")
    private LocalDateTime appointmentAt;

    @Schema(description = "디자이너 명", example = "123")
    private String designerName;

    @Schema(description = "사용자 명", example = "123")
    private String userName;

    @Schema(description = "작업일시", example = "123")
    private LocalDateTime workAt;

    @Schema(description = "작업자 Id", example = "123")
    private String workId;

}

