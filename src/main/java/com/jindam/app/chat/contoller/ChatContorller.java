package com.jindam.app.chat.contoller;

import com.jindam.app.chat.model.ChatRoomDetailRequestDto;
import com.jindam.app.chat.model.ChatRoomMemberResponseDto;
import com.jindam.app.chat.service.ChatService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "채팅 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/chat")
@Slf4j
public class ChatContorller extends MasterController {

    private final ChatService chatService;

    @Operation(summary = "채팅방 목록 조회", description = "로그인 유저가 참여중인 채팅방 목록 조회(페이징)")
    @GetMapping("")
    public ApiResultDto<PagingResponseDto<ChatRoomMemberResponseDto>> selectListDesignerPaging(ChatRoomDetailRequestDto request) {

        ApiResultDto<PagingResponseDto<ChatRoomMemberResponseDto>> apiResultVo = new ApiResultDto<>();
        PagingResponseDto<ChatRoomMemberResponseDto> result;

        result = chatService.selectChatRoomPaging(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }

}
