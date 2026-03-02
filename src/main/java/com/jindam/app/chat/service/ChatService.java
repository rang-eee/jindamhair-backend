package com.jindam.app.chat.service;

import com.jindam.app.chat.mapper.ChatMapper;
import com.jindam.app.chat.model.ChatInsertRequestDto;
import com.jindam.app.chat.model.ChatRoomDetailRequestDto;
import com.jindam.app.chat.model.ChatRoomMemberResponseDto;
import com.jindam.app.notification.exception.NotificationException;
import com.jindam.base.base.PagingService;
import com.jindam.base.dto.PagingResponseDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class ChatService extends PagingService {

    private final ChatMapper chatMapper;

    public int sendChat(ChatInsertRequestDto request) {

        ChatRoomMemberResponseDto chatRoomCHK = chatMapper.selectChatRoomByUserId(request);

        // 채팅방이 존재하는지 체크
        if (chatRoomCHK == null) {
            int insertChatRoomResult = chatMapper.insertChatRoom(request);
            if (insertChatRoomResult == 0) {
                throw new NotificationException(NotificationException.Reason.INVALID_ID);
            }
        }

        // 메시지 전송
        int insertChatMessageResult = chatMapper.insertChatMessage(request);
        if (insertChatMessageResult == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }

        return insertChatMessageResult;
    }

    public PagingResponseDto<ChatRoomMemberResponseDto> selectChatRoomPaging(ChatRoomDetailRequestDto request) {

        PagingResponseDto<ChatRoomMemberResponseDto> pagingResult = findData(chatMapper, "selectChatRoomPaging", request);

        return pagingResult;
    }

    /**
     * 로그인 유저가 속한 채팅방 목록 + 멤버 정보 + 최신 메시지 조회 Flutter ChatRoomModel 호환 구조(memberIds, memberInfos, title 등)로 변환하여 반환
     */
    public List<ChatRoomMemberResponseDto> selectChatRoomList(ChatRoomDetailRequestDto request) {

        // 1) 본인이 속한 채팅방 기본 정보 (최신 메시지, 안읽은 수 포함)
        List<ChatRoomMemberResponseDto> rooms = chatMapper.selectChatRoomList(request);
        if (rooms == null || rooms.isEmpty()) {
            return Collections.emptyList();
        }

        // 2) 채팅방 ID 수집 → 멤버 + 유저 정보 일괄 조회
        List<String> chatroomIds = rooms.stream()
            .map(ChatRoomMemberResponseDto::getChatroomId)
            .distinct()
            .collect(Collectors.toList());

        List<Map<String, Object>> memberRows = chatMapper.selectChatRoomMembers(chatroomIds);

        // 3) chatroomId → 멤버 목록 그룹핑
        Map<String, List<Map<String, Object>>> membersByRoom = memberRows.stream()
            .collect(Collectors.groupingBy(row -> (String) row.get("chatroomId")));

        // 4) 각 채팅방에 memberIds, memberInfos, title 세팅
        for (ChatRoomMemberResponseDto room : rooms) {
            List<Map<String, Object>> members = membersByRoom.getOrDefault(room.getChatroomId(), Collections.emptyList());

            // memberIds
            List<String> memberIds = members.stream()
                .map(m -> (String) m.get("uid"))
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
            room.setMemberIds(memberIds);

            // memberInfos: { uid: { lastSeenDt, userName, userNickname, profilePhotoFileId } }
            Map<String, Object> memberInfos = new LinkedHashMap<>();
            StringBuilder titleBuilder = new StringBuilder();
            for (Map<String, Object> m : members) {
                String memberUid = (String) m.get("uid");
                if (memberUid == null)
                    continue;

                Map<String, Object> info = new LinkedHashMap<>();
                info.put("lastSeenDt", m.get("lastReadAt"));
                info.put("userName", m.get("userName"));
                info.put("userNickname", m.get("userNickname"));
                info.put("profilePhotoFileId", m.get("profilePhotoFileId"));
                memberInfos.put(memberUid, info);

                // 본인이 아닌 상대방 이름으로 title 생성
                if (!memberUid.equals(request.getUid())) {
                    String name = m.get("userNickname") != null ? (String) m.get("userNickname") : (String) m.get("userName");
                    if (name != null) {
                        if (titleBuilder.length() > 0)
                            titleBuilder.append(", ");
                        titleBuilder.append(name);
                    }
                }
            }
            room.setMemberInfos(memberInfos);

            // title: 채팅방명이 있으면 그것을, 없으면 상대방 이름
            if (room.getChatroomName() != null && !room.getChatroomName()
                .isBlank()) {
                room.setTitle(room.getChatroomName());
            } else {
                room.setTitle(titleBuilder.length() > 0 ? titleBuilder.toString() : "채팅방");
            }
        }

        return rooms;
    }

}
