package com.jindam.app.chat.service;

import com.jindam.app.chat.mapper.ChatMapper;
import com.jindam.app.chat.model.ChatInsertRequestDto;
import com.jindam.app.chat.model.ChatRoomMemberResponseDto;
import com.jindam.app.notification.exception.NotificationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class ChatService {

    private final ChatMapper chatMapper;

    public int sendChat(ChatInsertRequestDto request) {

        ChatRoomMemberResponseDto chatRoomCHK = chatMapper.selectChatRoomByUserId(request);

        //채팅방이 존재하는지 체크
        if (chatRoomCHK == null) {
            int insertChatRoomResult = chatMapper.insertChatRoom(request);
            if (insertChatRoomResult == 0) {
                throw new NotificationException(NotificationException.Reason.INVALID_ID);
            }
        }

        //메시지 전송
        int insertChatMessageResult = chatMapper.insertChatMessage(request);
        if (insertChatMessageResult == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }

        return insertChatMessageResult;
    }

}
