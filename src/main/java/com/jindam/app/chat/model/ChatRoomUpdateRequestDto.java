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
@Schema(description = "채팅방 업데이트 요청 모델")
public class ChatRoomUpdateRequestDto {

	@Schema(description = "채팅방 ID", required = true)
	private String chatroomId;

	@Schema(description = "사용자 ID", required = true)
	private String uid;

	@Schema(description = "최종 읽음 일시")
	private LocalDateTime lastReadAt;
}
