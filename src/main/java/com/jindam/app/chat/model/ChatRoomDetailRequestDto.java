package com.jindam.app.chat.model;

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
@Schema(description = "채팅방 상세 요청 모델")
public class ChatRoomDetailRequestDto extends PagingRequestDto {
    @Schema(description = "채팅방 멤버 ID", example = "123")
    private String chatroomMemberId;

    @Schema(description = "채팅방 ID", example = "123")
    private String chatroomId;

    @Schema(description = "사용자ID", example = "123")
    private String uid;

    @Schema(description = "채팅방 명", example = "123")
    private String chatroomName;

    @Schema(description = "최종 읽음 일시", example = "123")
    private LocalDateTime lastReadAt;

    @Schema(description = "작업 일시", example = "123")
    private LocalDateTime workAt;

    @Schema(description = "작업자 ID", example = "123")
    private String wokrId;

}

