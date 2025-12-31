package com.jindam.app.notification.service;

import com.jindam.app.notification.mapper.NotificationMapper;
import com.jindam.app.notification.model.NotificationInsertRequestDto;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class NotificationService extends PagingService {

    private final NotificationMapper notificationMapper;

    public void insertNotification(NotificationInsertRequestDto request) {
        int result = notificationMapper.insertNotification(request);
    }

}
