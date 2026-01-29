package com.jindam.app.notification.service;

import com.jindam.app.notification.mapper.NotificationMapper;
import com.jindam.app.notification.model.NotificationDeletePushRequestDto;
import com.jindam.app.notification.model.NotificationInsertCenterRequestDto;
import com.jindam.app.notification.model.NotificationInsertPushRequestDto;
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

    //알림 테이블인서트
    public int insertNotification(NotificationInsertRequestDto request) {
        int result = notificationMapper.insertNotification(request);
        return result;
    }

    //알림센터 인서트
    public int insertNotificationCenter(NotificationInsertCenterRequestDto request) {
        int result = notificationMapper.insertNotificationCenter(request);
        return result;
    }

    //사용자 푸쉬 인서트
    public int insertNotificationPush(NotificationInsertPushRequestDto request) {
        int result = notificationMapper.insertNotificationPush(request);
        return result;
    }

    //사용자 푸쉬 삭제처리
    public int deleteNotificationPush(NotificationDeletePushRequestDto request) {
        int result = notificationMapper.deleteNotificationPush(request);
        return result;
    }

}
