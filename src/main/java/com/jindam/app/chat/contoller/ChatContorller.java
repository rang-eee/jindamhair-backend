package com.jindam.app.chat.contoller;

import com.jindam.app.chat.service.ChatService;
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
public class ChatContorller extends MasterController {

    private final ChatService notificationService;

}
