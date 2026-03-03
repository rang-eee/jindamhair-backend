package com.jindam.app.chat.contoller;

import com.jindam.app.chat.model.ChatRoomDetailRequestDto;
import com.jindam.app.chat.model.ChatRoomMemberResponseDto;
import com.jindam.app.chat.model.ChatRoomCreateRequestDto;
import com.jindam.app.chat.model.ChatRoomUpdateRequestDto;
import com.jindam.app.chat.model.ChatMessageCreateRequestDto;
import com.jindam.app.chat.model.ChatMessageResponseDto;
import com.jindam.app.chat.service.ChatService;
import com.jindam.base.base.MasterController;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.base.dto.PagingResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;

@Tag(name = "채팅 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/chatRooms")
@Slf4j
public class ChatContorller extends MasterController {

    private final ChatService chatService;

    @Operation(summary = "채팅방 목록 조회", description = "로그인 유저가 참여중인 채팅방 목록 조회")
    @GetMapping("")
    public ApiResultDto<List<ChatRoomMemberResponseDto>> selectListChatRoom(ChatRoomDetailRequestDto request) {

        ApiResultDto<List<ChatRoomMemberResponseDto>> apiResultVo = new ApiResultDto<>();
        List<ChatRoomMemberResponseDto> result;

        result = chatService.selectChatRoomList(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }

    @Operation(summary = "채팅방 단건 조회", description = "채팅방 ID로 단건 조회")
    @GetMapping("/one")
    public ApiResultDto<ChatRoomMemberResponseDto> selectOneChatRoom(ChatRoomDetailRequestDto request) {
        ApiResultDto<ChatRoomMemberResponseDto> apiResultVo = new ApiResultDto<>();
        ChatRoomMemberResponseDto result = chatService.selectChatRoomById(request.getChatroomId(), request.getUid());
        apiResultVo.setData(result);
        return apiResultVo;
    }

    @Operation(summary = "채팅방 생성", description = "채팅방을 생성합니다.")
    @PostMapping("")
    public ApiResultDto<ChatRoomMemberResponseDto> createChatRoom(@RequestBody ChatRoomCreateRequestDto request) {
        ApiResultDto<ChatRoomMemberResponseDto> apiResultVo = new ApiResultDto<>();
        ChatRoomMemberResponseDto result = chatService.createChatRoom(request);
        apiResultVo.setData(result);
        return apiResultVo;
    }

    @Operation(summary = "채팅 메시지 목록 조회", description = "채팅방 메시지 목록 조회. since 파라미터가 있으면 해당 시점 이후 메시지만 반환합니다.")
    @GetMapping("/{roomId}/messages")
    public ApiResultDto<List<ChatMessageResponseDto>> selectListMessages(@PathVariable("roomId") String roomId, @RequestParam(value = "since", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime since) {
        ApiResultDto<List<ChatMessageResponseDto>> apiResultVo = new ApiResultDto<>();
        List<ChatMessageResponseDto> result = chatService.selectChatMessages(roomId, since);
        apiResultVo.setData(result);
        return apiResultVo;
    }

    @Operation(summary = "채팅 메시지 생성", description = "채팅방 메시지를 생성합니다.")
    @PostMapping("/{roomId}/messages")
    public ApiResultDto<Object> insertMessage(@PathVariable("roomId") String roomId, @RequestBody ChatMessageCreateRequestDto request) {
        ApiResultDto<Object> apiResultVo = new ApiResultDto<>();
        chatService.insertChatMessage(roomId, request);
        return apiResultVo;
    }

    @Operation(summary = "채팅방 업데이트", description = "채팅방 정보(읽음 시간 등)를 업데이트합니다.")
    @PatchMapping("")
    public ApiResultDto<ChatRoomMemberResponseDto> updateChatRoom(@RequestBody ChatRoomUpdateRequestDto request) {
        ApiResultDto<ChatRoomMemberResponseDto> apiResultVo = new ApiResultDto<>();
        ChatRoomMemberResponseDto result = chatService.updateChatRoom(request);
        apiResultVo.setData(result);
        return apiResultVo;
    }

    @Operation(summary = "채팅방 목록 조회(페이징)", description = "로그인 유저가 참여중인 채팅방 목록 조회(페이징)")
    @GetMapping("/paging")
    public ApiResultDto<PagingResponseDto<ChatRoomMemberResponseDto>> selectListChatRoomPaging(ChatRoomDetailRequestDto request) {

        ApiResultDto<PagingResponseDto<ChatRoomMemberResponseDto>> apiResultVo = new ApiResultDto<>();
        PagingResponseDto<ChatRoomMemberResponseDto> result;

        result = chatService.selectChatRoomPaging(request);
        apiResultVo.setData(result);

        return apiResultVo;

    }

}
