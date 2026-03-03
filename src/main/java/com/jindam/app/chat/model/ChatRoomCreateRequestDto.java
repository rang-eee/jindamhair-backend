package com.jindam.app.chat.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "채팅방 생성 요청 모델")
public class ChatRoomCreateRequestDto {

	@Schema(description = "채팅방 ID")
	private String chatroomId;

	@Schema(description = "채팅방 멤버 UID 목록")
	private List<String> memberIds;

	@Schema(description = "채팅방 제목(옵션)")
	private String title;

	@Schema(description = "생성 일시")
	private LocalDateTime createAt;

	@Schema(description = "수정 일시")
	private LocalDateTime updateAt;

	@Schema(description = "생성 사용자 UID")
	private String createUid;
}
