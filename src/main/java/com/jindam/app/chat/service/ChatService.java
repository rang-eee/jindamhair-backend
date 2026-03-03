package com.jindam.app.chat.service;

import com.jindam.app.chat.mapper.ChatMapper;
import com.jindam.app.chat.model.ChatInsertRequestDto;
import com.jindam.app.chat.model.ChatRoomDetailRequestDto;
import com.jindam.app.chat.model.ChatRoomMemberResponseDto;
import com.jindam.app.chat.model.ChatRoomCreateRequestDto;
import com.jindam.app.chat.model.ChatMessageCreateRequestDto;
import com.jindam.app.chat.model.ChatMessageResponseDto;
import com.jindam.app.chat.model.ChatRoomUpdateRequestDto;
import com.jindam.app.chat.model.ChatMemberInfoDto;
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
            ChatRoomCreateRequestDto createRequest = ChatRoomCreateRequestDto.builder()
                .memberIds(Arrays.asList(request.getWriteUid(), request.getReceiverId()))
                .title(null)
                .createAt(LocalDateTime.now())
                .updateAt(LocalDateTime.now())
                .createUid(request.getWriteUid())
                .build();

            int insertChatRoomResult = chatMapper.insertChatRoom(createRequest);
            if (insertChatRoomResult == 0) {
                throw new NotificationException(NotificationException.Reason.INVALID_ID);
            }

            request.setChatroomId(createRequest.getChatroomId());
        } else {
            request.setChatroomId(chatRoomCHK.getChatroomId());
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

                ChatMemberInfoDto info = ChatMemberInfoDto.builder()
                    .lastSeenDt(m.get("lastReadAt"))
                    .userName((String) m.get("userName"))
                    .userNickname((String) m.get("userNickname"))
                    .profilePhotoFileId((String) m.get("profilePhotoFileId"))
                    .build();
                memberInfos.put(memberUid, info.toMap());

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

    /**
     * 채팅방 생성 (멤버 포함)
     */
    @Transactional
    public ChatRoomMemberResponseDto createChatRoom(ChatRoomCreateRequestDto request) {
        if (request.getMemberIds() == null || request.getMemberIds()
            .isEmpty()) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }

        // 생성자 UID 기본값
        if (request.getCreateUid() == null) {
            request.setCreateUid(request.getMemberIds()
                .get(0));
        }

        int insertRoom = chatMapper.insertChatRoom(request);
        if (insertRoom == 0 || request.getChatroomId() == null) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }

        chatMapper.insertChatRoomMember(request);

        // 생성자 기준 목록 조회 후 단건 반환
        ChatRoomDetailRequestDto detail = ChatRoomDetailRequestDto.builder()
            .uid(request.getCreateUid())
            .build();

        List<ChatRoomMemberResponseDto> rooms = selectChatRoomList(detail);
        return rooms.stream()
            .filter(r -> request.getChatroomId()
                .equals(r.getChatroomId()))
            .findFirst()
            .orElseGet(() -> selectChatRoomById(request.getChatroomId(), request.getCreateUid()));
    }

    /**
     * 채팅방 단건 조회
     */
    public ChatRoomMemberResponseDto selectChatRoomById(String chatroomId, String uid) {
        ChatRoomMemberResponseDto room = chatMapper.selectChatRoomById(chatroomId);
        if (room == null) {
            return null;
        }

        List<Map<String, Object>> memberRows = chatMapper.selectChatRoomMembers(Collections.singletonList(chatroomId));
        Map<String, List<Map<String, Object>>> membersByRoom = memberRows.stream()
            .collect(Collectors.groupingBy(row -> (String) row.get("chatroomId")));

        List<Map<String, Object>> members = membersByRoom.getOrDefault(chatroomId, Collections.emptyList());

        List<String> memberIds = members.stream()
            .map(m -> (String) m.get("uid"))
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
        room.setMemberIds(memberIds);

        Map<String, Object> memberInfos = new LinkedHashMap<>();
        StringBuilder titleBuilder = new StringBuilder();
        for (Map<String, Object> m : members) {
            String memberUid = (String) m.get("uid");
            if (memberUid == null)
                continue;

            ChatMemberInfoDto info = ChatMemberInfoDto.builder()
                .lastSeenDt(m.get("lastReadAt"))
                .userName((String) m.get("userName"))
                .userNickname((String) m.get("userNickname"))
                .profilePhotoFileId((String) m.get("profilePhotoFileId"))
                .build();
            memberInfos.put(memberUid, info.toMap());

            if (uid != null && !memberUid.equals(uid)) {
                String name = m.get("userNickname") != null ? (String) m.get("userNickname") : (String) m.get("userName");
                if (name != null) {
                    if (titleBuilder.length() > 0)
                        titleBuilder.append(", ");
                    titleBuilder.append(name);
                }
            }
        }
        room.setMemberInfos(memberInfos);
        if (room.getChatroomName() != null && !room.getChatroomName()
            .isBlank()) {
            room.setTitle(room.getChatroomName());
        } else {
            room.setTitle(titleBuilder.length() > 0 ? titleBuilder.toString() : "채팅방");
        }

        return room;
    }

    /**
     * 채팅 메시지 목록 조회
     */
    public List<ChatMessageResponseDto> selectChatMessages(String chatroomId, LocalDateTime since) {
        return chatMapper.selectChatMessageList(chatroomId, since);
    }

    /**
     * 채팅 메시지 등록
     */
    @Transactional
    public void insertChatMessage(String chatroomId, ChatMessageCreateRequestDto request) {
        request.setChatroomId(chatroomId);

        // deleteMemberIds -> 문자열 배열 필드로 저장
        if (request.getDeleteMemberIds() != null && !request.getDeleteMemberIds()
            .isEmpty()) {
            request.setDeleteMemberUidArr(String.join(",", request.getDeleteMemberIds()));
        }

        int result = chatMapper.insertChatMessageV2(request);
        if (result == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }
    }

    /**
     * 채팅방 멤버 읽음 시간 업데이트 후 채팅방 정보 반환
     */
    @Transactional
    public ChatRoomMemberResponseDto updateChatRoom(ChatRoomUpdateRequestDto request) {
        // last_read_at 업데이트
        if (request.getLastReadAt() != null) {
            chatMapper.updateChatRoomMemberLastRead(request);
        }

        // 업데이트 후 채팅방 정보 반환
        return selectChatRoomById(request.getChatroomId(), request.getUid());
    }

}
