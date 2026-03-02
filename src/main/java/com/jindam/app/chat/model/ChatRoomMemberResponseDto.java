package com.jindam.app.chat.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "채팅방멤버 응답 모델")
public class ChatRoomMemberResponseDto {
    @Schema(description = "채팅방 ID (Flutter 호환)")
    public String getId() {
        return chatroomId;
    }

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

    @Schema(description = "채팅방 생성 일시")
    private LocalDateTime createAt;

    @Schema(description = "채팅방 최종 수정 일시 (최신 메시지 기준)")
    private LocalDateTime updateAt;

    /* ── Flutter ChatRoomModel 호환 필드 ── */

    @Schema(description = "채팅방 멤버 UID 목록")
    private List<String> memberIds;

    @Schema(description = "채팅방 멤버 정보 {uid: {lastSeenDt, userName, userNickname, profilePhotoFileId}}")
    private Map<String, Object> memberInfos;

    @Schema(description = "채팅방 제목 (상대방 이름 기반 자동 생성)")
    private String title;

    @Schema(description = "마지막 메시지 내용")
    private String lastMessage;

    @Schema(description = "마지막 메시지 일시")
    private LocalDateTime lastMessageAt;

    @Schema(description = "마지막 메시지 작성자 UID")
    private String lastMessageAuthorId;

    @Schema(description = "안읽은 메시지 수")
    private Integer unreadCount;

}
