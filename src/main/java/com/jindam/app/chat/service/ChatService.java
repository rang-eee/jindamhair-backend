package com.jindam.app.chat.service;

import com.jindam.app.chat.mapper.ChatMapper;
import com.jindam.app.chat.model.ChatInsertRequestDto;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class ChatService extends PagingService {

    private final ChatMapper notificationMapper;

    public void insertNotification(ChatInsertRequestDto request) {
        int result = notificationMapper.insertNotification(request);
    }

}
