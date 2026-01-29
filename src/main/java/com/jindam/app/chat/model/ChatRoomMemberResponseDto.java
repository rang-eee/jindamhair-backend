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
@Schema(description = "예약 상세 응답 모델")
public class ChatRoomMemberResponseDto {
    @Schema(description = "채팅방 멤버 ID")
    private String chatroomMemberId;

    @Schema(description = "채팅방 ID")
    private String chatroomId;

    @Schema(description = "사용자ID")
    private String uid;

    @Schema(description = "채팅방 명")
    private String chatroomName;

    @Schema(description = "최종 읽음 일시")
    private LocalDateTime lastReadAt;

}

