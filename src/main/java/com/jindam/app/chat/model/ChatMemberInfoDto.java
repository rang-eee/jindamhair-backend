package com.jindam.app.chat.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.util.LinkedHashMap;
import java.util.Map;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "채팅방 멤버 정보")
public class ChatMemberInfoDto {

	@Schema(description = "최종 읽음 일시")
	private Object lastSeenDt;

	@Schema(description = "사용자 이름")
	private String userName;

	@Schema(description = "사용자 닉네임")
	private String userNickname;

	@Schema(description = "프로필 사진 파일 ID")
	private String profilePhotoFileId;

	public Map<String, Object> toMap() {
		Map<String, Object> map = new LinkedHashMap<>();
		map.put("lastSeenDt", lastSeenDt);
		map.put("userName", userName);
		map.put("userNickname", userNickname);
		map.put("profilePhotoFileId", profilePhotoFileId);
		return map;
	}
}
