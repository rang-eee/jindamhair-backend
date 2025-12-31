package com.jindam.app.notification.contoller;

import com.jindam.app.notification.service.NotificationService;
import com.jindam.base.base.MasterController;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "알림 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/notification")
@Slf4j
public class NotificationContorller extends MasterController {

    private final NotificationService notificationService;

}
