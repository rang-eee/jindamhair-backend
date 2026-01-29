package com.jindam.app.notification.model;

import com.jindam.base.code.PushTypeCode;
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
@Schema(description = "사용자 푸쉬 생성 요청 모델")
public class NotificationInsertPushRequestDto {

    @Schema(description = "사용자 푸시 ID", example = "123")
    private String userPushId;

    @Schema(description = "송신자 사용자ID", example = "123")
    private String senderUid;

    @Schema(description = "수신자 사용자ID", example = "123")
    private String receiverUid;

    @Schema(description = "푸시 제목", example = "123")
    private String pushTitle;

    @Schema(description = "푸시 내용", example = "123")
    private String pushContent;

    @Schema(description = "송신 일시", example = "123")
    private LocalDateTime sendAt;

    @Schema(description = "송신 여부", example = "Y")
    private String sendYn;

    @Schema(description = "송신 완료 일시", example = "123")
    private LocalDateTime sendCompleteAt;

    @Schema(description = "푸시 유형 코드", example = "123")
    private PushTypeCode pushTypeCode;

    @Schema(description = "푸시 연계 값", example = "123")
    private String pushLinkVal;

    @Schema(description = "작업일시", example = "123")
    private LocalDateTime workAt;

    @Schema(description = "작업자 ID", example = "123")
    private String workId;

}

