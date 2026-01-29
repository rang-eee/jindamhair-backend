package com.jindam.app.chat.mapper;

import com.jindam.app.chat.model.ChatInsertRequestDto;
import com.jindam.app.chat.model.ChatRoomDetailRequestDto;
import com.jindam.app.chat.model.ChatRoomMemberResponseDto;

import java.util.List;

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
     * 목록 페이징 처리 후 조회
     */
    List<ChatRoomMemberResponseDto> selectChatRoomPaging(ChatRoomDetailRequestDto request);

    /**
     * 목록 카운트 조회
     */
    int selectChatRoomPagingCount(ChatRoomDetailRequestDto request);
}

