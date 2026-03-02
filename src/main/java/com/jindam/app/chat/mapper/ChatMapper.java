package com.jindam.app.chat.mapper;

import com.jindam.app.chat.model.ChatInsertRequestDto;
import com.jindam.app.chat.model.ChatRoomDetailRequestDto;
import com.jindam.app.chat.model.ChatRoomMemberResponseDto;

import java.util.List;
import java.util.Map;

/**
 * ExampleMapper 인터페이스
 *
 * <p>
 * 데이터베이스와 상호작용하는 MyBatis Mapper로, Example 관련 CRUD 및 페이징 처리를 위한 메서드를 정의합니다.
 * </p>
 */
public interface ChatMapper {
    ChatRoomMemberResponseDto selectChatRoomByUserId(ChatInsertRequestDto request);

    int insertChatRoom(ChatInsertRequestDto request);

    int insertChatMessage(ChatInsertRequestDto request);

    /**
     * 목록 조회 (단순 리스트)
     */
    List<ChatRoomMemberResponseDto> selectChatRoomList(ChatRoomDetailRequestDto request);

    /**
     * 목록 페이징 처리 후 조회
     */
    List<ChatRoomMemberResponseDto> selectChatRoomPaging(ChatRoomDetailRequestDto request);

    /**
     * 목록 카운트 조회
     */
    int selectChatRoomPagingCount(ChatRoomDetailRequestDto request);

    /**
     * 채팅방 ID 목록으로 멤버 + 유저 정보 일괄 조회
     */
    List<Map<String, Object>> selectChatRoomMembers(List<String> chatroomIds);
}
