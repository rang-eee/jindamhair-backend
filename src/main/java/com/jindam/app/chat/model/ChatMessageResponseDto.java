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
@Schema(description = "채팅 메시지 응답 모델 (Flutter 호환)")
public class ChatMessageResponseDto {

	@Schema(description = "메시지 ID")
	private String id;

	@Schema(description = "메시지 타입 코드")
	private String messageType;

	@Schema(description = "메시지 내용 타입 코드")
	private String messageTextType;

	@Schema(description = "메시지 내용 타입명")
	private String messageTextTypeName;

	@Schema(description = "작성자 UID")
	private String authorId;

	@Schema(description = "메시지 내용")
	private String message;

	@Schema(description = "생성 일시")
	private LocalDateTime createAt;

	@Schema(description = "삭제된 멤버 UID 목록")
	private List<String> deleteMemberIds;

	@Schema(description = "예약 ID")
	private String appointmentId;
}
