package com.jindam.app.chat.model;

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
@Schema(description = "채팅방 메세지 생성 모델")
public class ChatRoomMessageInsertDto {
    @Schema(description = "채팅 메시지 ID")
    private String chatMessageId;

    @Schema(description = "채팅방 ID")
    private String chatroomId;

    @Schema(description = "작성 사용자ID")
    private String writeUid;

    @Schema(description = "채팅 메시지 유형 코드")
    private String chatMessageTypeCode;

    @Schema(description = "채팅 메시지 내용 유형 코드")
    private String chatMessageContentTypeCode;

    @Schema(description = "채팅 메시지 내용")
    private String chatMessageContent;

    @Schema(description = "삭제 멤버 사용자ID 배열")
    private String deleteMemberUidArr;

    @Schema(description = "예약 ID")
    private String appointmentId;

    @Schema(description = "작업 일시")
    private LocalDateTime workAt;

    @Schema(description = "작업 ID")
    private String workId;

}

