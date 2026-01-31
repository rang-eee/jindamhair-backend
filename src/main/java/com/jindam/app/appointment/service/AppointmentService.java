package com.jindam.app.appointment.service;

import com.jindam.app.appointment.exception.AppointmentException;
import com.jindam.app.appointment.mapper.AppointmentMapper;
import com.jindam.app.appointment.model.*;
import com.jindam.app.chat.model.ChatInsertRequestDto;
import com.jindam.app.chat.service.ChatService;
import com.jindam.app.notification.exception.NotificationException;
import com.jindam.app.notification.model.NotificationDeletePushRequestDto;
import com.jindam.app.notification.model.NotificationInsertCenterRequestDto;
import com.jindam.app.notification.model.NotificationInsertPushRequestDto;
import com.jindam.app.notification.model.NotificationInsertRequestDto;
import com.jindam.app.notification.service.NotificationService;
import com.jindam.base.base.PagingService;
import com.jindam.base.code.*;
import com.jindam.base.dto.PagingResponseDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static com.jindam.base.code.AppointmentStartTypeCode.APSR003;

@Service
@RequiredArgsConstructor
@Slf4j
public class AppointmentService extends PagingService {
    private final AppointmentMapper appointmentMapper;
    private final NotificationService notificationService;
    private final ChatService chatService;

    public AppointmentDetailResponseDto selectAppointmentById(AppointmentDetailRequestDto request) {
        AppointmentDetailResponseDto result;
        result = appointmentMapper.selectAppointmentById(request);
        return result;
    }

    public PagingResponseDto<AppointmentDetailResponseDto> selectAppointmentByCustIdPaging(AppointmentDetailRequestDto request) {

        PagingResponseDto<AppointmentDetailResponseDto> pagingResult = findData(appointmentMapper, "selectAppointmentByCustIdPaging", request);

        return pagingResult;
    }

    public PagingResponseDto<AppointmentDetailResponseDto> selectAppointmentByDesignerIdPaging(AppointmentDetailRequestDto request) {

        PagingResponseDto<AppointmentDetailResponseDto> pagingResult = findData(appointmentMapper, "selectAppointmentByCustIdPaging", request);

        return pagingResult;
    }

    public List<AppointmentDetailResponseDto> selectAppointmentByEmail(AppointmentEmailRequestDto request) {
        return appointmentMapper.selectAppointmentByEmail(request);
    }

    public AppointmentDetailResponseDto insertAppointment(AppointmentInsertRequestDto request) {

        int result = 0;
        result = appointmentMapper.insertAppointment(request);

        // 예약 마스터 등록 실패
        if (result == 0) {
            throw new AppointmentException(AppointmentException.Reason.INVALID_ID);
        }

        /* to-do
         * 예약성공시
         *
         * 예약 스타일 테이블 인서트
         *
         * 자동확정 여부에 따라서 분기처리
         *
         * 자동확정시 예약상태 확정으로업데이트
         * 알림등록 (요청응답)
         * 알림센터 인서트(고객디자이너 둘다)
         * 알림 테이블 인서트
         * 채팅 인서트 채팅방 없으면 생성하고
         *
         * 아닐시
         * 예약변경으로 들어온 케이스
         * 알림등록(요청응답), 알림센터 등록(고객디자이너 둘다) ,기존 알림 푸쉬삭제 ,예약 관련 알림 신규 푸쉬인서트, 채팅발송
         *
         *
         * 신규 예약 케이스
         * 알림등록(요청응답), 알림센터 등록(고객디자이너 둘다), 신규푸쉬인서트(전날 17시, 당일 2시간전) , 채팅발송
         *
         * */

        //예약스타일 인서트
        List<AppointmentTreatmentInsertRequestDto> aList = request.getTreatmentList();
        int resultInsertAppTreat = 0;

        for (AppointmentTreatmentInsertRequestDto input : aList) {

            resultInsertAppTreat = appointmentMapper.insertAppointmentTreatment(input);

            if (resultInsertAppTreat == 0) {//예약시술테이블 인서트 실패
                throw new AppointmentException(AppointmentException.Reason.INVALID_ID);
            }
        }

        //예약 자동처리여부 확인
        AppointmentDetailResponseDto tt;
        AppointmentDetailRequestDto insertRequestDto = AppointmentDetailRequestDto.from(request);
        //        String newId = request.getAppointmentId();
        //        insertRequestDto.setAppointmentId(newId);
        tt = appointmentMapper.selectAppointmentById(insertRequestDto);
        String autoYn = tt.getDesignerDesignerAppointmentAutomaticConfirmYn();

        if (autoYn.equals("Y")) {
            //예약확정
            confirmAppointment(request);
        } else {
            //예약 변경건 고객 또는 디자이너 요청
            if ((request.getAppointmentStartTypeCode() == APSR003) || (request.getAppointmentStartTypeCode() == AppointmentStartTypeCode.APSR004)) {
                //기존  에약건에 대한 푸쉬 알림 삭제
                NotificationDeletePushRequestDto deletePushDto = NotificationDeletePushRequestDto.builder()
                        .senderUid(request.getDesignerUid())
                        .receiverUid(request.getCustomerUid())
                        .build();

                int deletePushResult = notificationService.deleteNotificationPush(deletePushDto);
                if (deletePushResult == 0) {
                    throw new NotificationException(NotificationException.Reason.INVALID_ID);
                }
                AppointmentUpdateRequestDto updateRequestDto = AppointmentUpdateRequestDto.builder()
                        // 1. 식별자 정보
                        .appointmentId(request.getAppointmentId())
                        .customerUid(request.getCustomerUid())
                        .designerUid(request.getDesignerUid())
                        .shopId(request.getShopId())

                        // 2. 상태 및 결제 정보
                        .appointmentStatusCode(request.getAppointmentStatusCode())
                        .appointmentStartTypeCode(request.getAppointmentStartTypeCode())
                        .paymentMethodCode(request.getPaymentMethodCode())

                        // 3. 금액 정보
                        .totalAmount(request.getTotalAmount())
                        .appointmentAmount(request.getAppointmentAmount())

                        // 4. 일정 정보
                        .treatmentStartAt(request.getTreatmentStartAt())
                        .treatmentEndAt(request.getTreatmentEndAt())
                        .treatmentList(request.getTreatmentList())
                        .build();

                updateAppointment(updateRequestDto);
            }

        }

        AppointmentDetailResponseDto success = appointmentMapper.selectAppointmentById(insertRequestDto);
        return success;
    }

    public void confirmAppointment(AppointmentInsertRequestDto request) {
        //예약상태 업데이트
        AppointmentUpdateRequestDto updateDto = AppointmentUpdateRequestDto.builder()
                .appointmentId(request.getAppointmentId())
                .appointmentStatusCode(AppointmentStatusCode.APST005)
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        updateDto.setAppointmentStatusCode(AppointmentStatusCode.APST005);//예약완료
        int updateResult = appointmentMapper.updateAppointment(updateDto);

        if (updateResult == 0) { // 예약상태 변경 실패
            throw new AppointmentException(AppointmentException.Reason.INVALID_ID);
        }

        //알림테이블 인서트 (요청응답)
        NotificationInsertRequestDto notificationInsertRequestDtoCustomer = NotificationInsertRequestDto.builder()
                .notificationContent("예약확정_고객")
                .notificationTitle("예약제목")
                .notificationTopic("예약토픽")
                .receiverUid(request.getCustomerUid())
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        NotificationInsertRequestDto notificationInsertRequestDtoDesigner = NotificationInsertRequestDto.builder()
                .notificationContent("예약확정_디자이너")
                .notificationTitle("예약제목")
                .notificationTopic("예약토픽")
                .receiverUid(request.getDesignerUid())
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        //고객,디자이너 알림
        int insertNotiResultCustomer = notificationService.insertNotification(notificationInsertRequestDtoCustomer);
        int insertNotiResultDesinger = notificationService.insertNotification(notificationInsertRequestDtoDesigner);

        if (insertNotiResultCustomer == 0 || insertNotiResultDesinger == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }
        //알림센터 인서트
        NotificationInsertCenterRequestDto notificationInsertCenterRequestDtoCustomer = NotificationInsertCenterRequestDto.builder()
                .notificationTopic("")
                .eventClick("")
                .notificationTypeCode(NotificationTypeCode.NTTP002) //고객예약
                .notificationTitle("알림센터_고객")
                .notificationContent("")
                .receiverUid(request.getCustomerUid())
                .userName(request.getCustomerName())
                .appointmentId(request.getAppointmentId())
                .appointmentAt(LocalDateTime.now())
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        NotificationInsertCenterRequestDto notificationInsertCenterRequestDtoDesigner = NotificationInsertCenterRequestDto.builder()
                .notificationTopic("")
                .eventClick("")
                .notificationTypeCode(NotificationTypeCode.NTTP005)//디자이너예약
                .notificationTitle("알림센터_디자이너")
                .notificationContent("")
                .receiverUid(request.getDesignerUid())
                .designerName(request.getDesignerName())
                .appointmentId(request.getAppointmentId())
                .appointmentAt(LocalDateTime.now())
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        int insertNotiCenterResultCustomer = notificationService.insertNotificationCenter(notificationInsertCenterRequestDtoCustomer);
        int insertNotiCenterResultDesigner = notificationService.insertNotificationCenter(notificationInsertCenterRequestDtoDesigner);

        if (insertNotiCenterResultCustomer == 0 || insertNotiCenterResultDesigner == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }

        // 1. 현재 날짜(예약하는 날)와 시술 날짜 비교
        LocalDateTime now = LocalDateTime.now();
        LocalDate appointmentDate = now.toLocalDate();
        LocalDate treatmentDate = request.getTreatmentStartAt()
                .toLocalDate();

        if (!appointmentDate.equals(treatmentDate)) {
            // 전날 17시
            LocalDateTime sendTimeYesterday = request.getTreatmentStartAt()
                    .minusDays(1)
                    .withHour(17)
                    .withMinute(0)
                    .withSecond(0)
                    .withNano(0);
            // 2시간 전
            LocalDateTime sendTimeTwoHoursBefore = request.getTreatmentStartAt()
                    .minusHours(2);

            //전날 17시 푸쉬 인서트
            if (sendTimeYesterday.isAfter(now)) {
                NotificationInsertPushRequestDto notificationInsertPushRequestDtoCustomerYesterday = NotificationInsertPushRequestDto.builder()
                        .senderUid(request.getDesignerUid())
                        .receiverUid(request.getCustomerUid())
                        .pushContent("내일 " + request.getTreatmentStartAt() + " 예약이 있습니다.")
                        .pushTitle("전날 푸쉬")
                        .pushTypeCode(PushTypeCode.PSTP002)
                        .sendAt(sendTimeYesterday)
                        .workAt(LocalDateTime.now())
                        .workId(request.getDesignerUid())
                        .build();

                int insertNotiPushResultCustomerYesterDay = notificationService.insertNotificationPush(notificationInsertPushRequestDtoCustomerYesterday);
                if (insertNotiPushResultCustomerYesterDay == 0) {
                    throw new NotificationException(NotificationException.Reason.INVALID_ID);
                }
            }
            // 예약 2시간전 푸쉬 인서트
            if (sendTimeTwoHoursBefore.isAfter(now)) {
                NotificationInsertPushRequestDto notificationInsertPushRequestDtoCustomerTwohour = NotificationInsertPushRequestDto.builder()
                        .senderUid(request.getDesignerUid())
                        .receiverUid(request.getCustomerUid())
                        .pushContent("2시간 뒤 예약이 있습니다.")
                        .pushTitle("당일 푸쉬")
                        .pushTypeCode(PushTypeCode.PSTP002)
                        .sendAt(sendTimeTwoHoursBefore)
                        .workAt(LocalDateTime.now())
                        .workId(request.getDesignerUid())
                        .build();

                int insertNotiPushResultDesignerTwohour = notificationService.insertNotificationPush(notificationInsertPushRequestDtoCustomerTwohour);
                if (insertNotiPushResultDesignerTwohour == 0) {
                    throw new NotificationException(NotificationException.Reason.INVALID_ID);
                }
            }

        }

        //채팅 보내기
        ChatInsertRequestDto chatInsertRequestDtoCustomer = ChatInsertRequestDto.builder()
                .writeUid(request.getCustomerUid())
                .receiverId(request.getDesignerUid())
                .chatMessageContentTypeCode(ChatMessageContentTypeCode.CMCT001) //일반
                .chatMessageTypeCode(ChatMessageTypeCode.CMTP001) // 텍스트
                .chatMessageContent("시술요청 하였습니다.")
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        ChatInsertRequestDto chatInsertRequestDtoDesigner = ChatInsertRequestDto.builder()
                .writeUid(request.getDesignerUid())
                .receiverId(request.getCustomerUid())
                .chatMessageContentTypeCode(ChatMessageContentTypeCode.CMCT001) //일반
                .chatMessageTypeCode(ChatMessageTypeCode.CMTP001) // 텍스트
                .chatMessageContent("시술일시 : " + request.getTreatmentStartAt() + " 예약되었습니다. 시술목록 :: " + request.getTreatmentList())
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        int sendChatResultCustomer = chatService.sendChat(chatInsertRequestDtoCustomer);
        int sendChatResultDesigner = chatService.sendChat(chatInsertRequestDtoDesigner);

        if (sendChatResultDesigner == 0 || sendChatResultCustomer == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }
    }

    public void updateAppointment(AppointmentUpdateRequestDto request) {

        //신규 예약건
        //예약상태 업데이트
        AppointmentUpdateRequestDto updateDto = AppointmentUpdateRequestDto.builder()
                .appointmentId(request.getAppointmentId())
                .appointmentStatusCode(AppointmentStatusCode.APST004)//예약요청
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        int updateResult = appointmentMapper.updateAppointment(updateDto);

        if (updateResult == 0) { // 예약상태 변경 실패
            throw new AppointmentException(AppointmentException.Reason.INVALID_ID);
        }

        //알림테이블 인서트 (요청응답)
        NotificationInsertRequestDto notificationInsertRequestDtoCustomer = NotificationInsertRequestDto.builder()
                .notificationContent("예약내용_고객")
                .notificationTitle("예약제목")
                .notificationTopic("예약토픽")
                .receiverUid(request.getCustomerUid())
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        NotificationInsertRequestDto notificationInsertRequestDtoDesigner = NotificationInsertRequestDto.builder()
                .notificationContent("예약내용_디자이너")
                .notificationTitle("예약제목")
                .notificationTopic("예약토픽")
                .receiverUid(request.getDesignerUid())
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        //고객,디자이너 알림
        int insertNotiResultCustomer = notificationService.insertNotification(notificationInsertRequestDtoCustomer);
        int insertNotiResultDesinger = notificationService.insertNotification(notificationInsertRequestDtoDesigner);

        if (insertNotiResultCustomer == 0 || insertNotiResultDesinger == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }
        //알림센터 인서트
        NotificationInsertCenterRequestDto notificationInsertCenterRequestDtoCustomer = NotificationInsertCenterRequestDto.builder()
                .notificationTopic("")
                .eventClick("")
                .notificationTypeCode(NotificationTypeCode.NTTP003) //고객수정
                .notificationTitle("알림센터_고객")
                .notificationContent("예약 수정됨")
                .receiverUid(request.getCustomerUid())
                .userName(request.getCustomerName())
                .appointmentId(request.getAppointmentId())
                .appointmentAt(LocalDateTime.now())
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        NotificationInsertCenterRequestDto notificationInsertCenterRequestDtoDesigner = NotificationInsertCenterRequestDto.builder()
                .notificationTopic("")
                .eventClick("")
                .notificationTypeCode(NotificationTypeCode.NTTP006)//디자이너수정
                .notificationTitle("알림센터_디자이너")
                .notificationContent("예약 수정됨")
                .receiverUid(request.getDesignerUid())
                .designerName(request.getDesignerName())
                .appointmentId(request.getAppointmentId())
                .appointmentAt(LocalDateTime.now())
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        int insertNotiCenterResultCustomer = notificationService.insertNotificationCenter(notificationInsertCenterRequestDtoCustomer);
        int insertNotiCenterResultDesigner = notificationService.insertNotificationCenter(notificationInsertCenterRequestDtoDesigner);

        if (insertNotiCenterResultCustomer == 0 || insertNotiCenterResultDesigner == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }

        // 1. 현재 날짜(예약하는 날)와 시술 날짜 비교
        LocalDateTime now = LocalDateTime.now();
        LocalDate appointmentDate = now.toLocalDate();
        LocalDate treatmentDate = request.getTreatmentStartAt()
                .toLocalDate();

        if (!appointmentDate.equals(treatmentDate)) {
            // 전날 17시
            LocalDateTime sendTimeYesterday = request.getTreatmentStartAt()
                    .minusDays(1)
                    .withHour(17)
                    .withMinute(0)
                    .withSecond(0)
                    .withNano(0);
            // 2시간 전
            LocalDateTime sendTimeTwoHoursBefore = request.getTreatmentStartAt()
                    .minusHours(2);

            //전날 17시 푸쉬 인서트
            if (sendTimeYesterday.isAfter(now)) {
                NotificationInsertPushRequestDto notificationInsertPushRequestDtoCustomerYesterday = NotificationInsertPushRequestDto.builder()
                        .senderUid(request.getDesignerUid())
                        .receiverUid(request.getCustomerUid())
                        .pushContent("내일 " + request.getTreatmentStartAt() + " 예약이 있습니다.")
                        .pushTitle("전날 푸쉬")
                        .pushTypeCode(PushTypeCode.PSTP002)
                        .sendAt(sendTimeYesterday)
                        .workAt(LocalDateTime.now())
                        .workId(request.getDesignerUid())
                        .build();

                int insertNotiPushResultCustomerYesterDay = notificationService.insertNotificationPush(notificationInsertPushRequestDtoCustomerYesterday);
                if (insertNotiPushResultCustomerYesterDay == 0) {
                    throw new NotificationException(NotificationException.Reason.INVALID_ID);
                }
            }
            // 예약 2시간전 푸쉬 인서트
            if (sendTimeTwoHoursBefore.isAfter(now)) {
                NotificationInsertPushRequestDto notificationInsertPushRequestDtoCustomerTwohour = NotificationInsertPushRequestDto.builder()
                        .senderUid(request.getDesignerUid())
                        .receiverUid(request.getCustomerUid())
                        .pushContent("2시간 뒤 예약이 있습니다.")
                        .pushTitle("당일 푸쉬")
                        .pushTypeCode(PushTypeCode.PSTP002)
                        .sendAt(sendTimeTwoHoursBefore)
                        .workAt(LocalDateTime.now())
                        .workId(request.getDesignerUid())
                        .build();

                int insertNotiPushResultDesignerTwohour = notificationService.insertNotificationPush(notificationInsertPushRequestDtoCustomerTwohour);
                if (insertNotiPushResultDesignerTwohour == 0) {
                    throw new NotificationException(NotificationException.Reason.INVALID_ID);
                }
            }

        }

        //채팅 보내기
        ChatInsertRequestDto chatInsertRequestDtoCustomer = ChatInsertRequestDto.builder()
                .writeUid(request.getCustomerUid())
                .receiverId(request.getDesignerUid())
                .chatMessageContentTypeCode(ChatMessageContentTypeCode.CMCT001) //일반
                .chatMessageTypeCode(ChatMessageTypeCode.CMTP001) // 텍스트
                .chatMessageContent("시술요청 하였습니다.")
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        ChatInsertRequestDto chatInsertRequestDtoDesigner = ChatInsertRequestDto.builder()
                .writeUid(request.getDesignerUid())
                .receiverId(request.getCustomerUid())
                .chatMessageContentTypeCode(ChatMessageContentTypeCode.CMCT001) //일반
                .chatMessageTypeCode(ChatMessageTypeCode.CMTP001) // 텍스트
                .chatMessageContent("시술일시 : " + request.getTreatmentStartAt() + " 예약되었습니다. 시술목록 :: " + request.getTreatmentList())
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        int sendChatResultCustomer = chatService.sendChat(chatInsertRequestDtoCustomer);
        int sendChatResultDesigner = chatService.sendChat(chatInsertRequestDtoDesigner);

        if (sendChatResultDesigner == 0 || sendChatResultCustomer == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }

    }

    public void deleteAppointment(AppointmentDeleteRequestDto request) {

        int deleteResult;
        //예약 취소처리
        deleteResult = appointmentMapper.deleteAppointment(request);

        if (deleteResult == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }

        //알림테이블 인서트 (요청응답)
        NotificationInsertRequestDto notificationInsertRequestDtoCustomer = NotificationInsertRequestDto.builder()
                .notificationContent("예약내용_고객")
                .notificationTitle("예약제목")
                .notificationTopic("예약토픽")
                .receiverUid(request.getCustomerUid())
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        NotificationInsertRequestDto notificationInsertRequestDtoDesigner = NotificationInsertRequestDto.builder()
                .notificationContent("예약내용_디자이너")
                .notificationTitle("예약제목")
                .notificationTopic("예약토픽")
                .receiverUid(request.getDesignerUid())
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        //고객,디자이너 알림
        int insertNotiResultCustomer = notificationService.insertNotification(notificationInsertRequestDtoCustomer);
        int insertNotiResultDesinger = notificationService.insertNotification(notificationInsertRequestDtoDesigner);

        if (insertNotiResultCustomer == 0 || insertNotiResultDesinger == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }
        //알림센터 인서트
        NotificationInsertCenterRequestDto notificationInsertCenterRequestDtoCustomer = NotificationInsertCenterRequestDto.builder()
                .notificationTopic("")
                .eventClick("")
                .notificationTypeCode(NotificationTypeCode.NTTP003) //고객수정
                .notificationTitle("알림센터_고객")
                .notificationContent("예약 취소됨")
                .receiverUid(request.getCustomerUid())
                .userName(request.getCustomerName())
                .appointmentId(request.getAppointmentId())
                .appointmentAt(LocalDateTime.now())
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        NotificationInsertCenterRequestDto notificationInsertCenterRequestDtoDesigner = NotificationInsertCenterRequestDto.builder()
                .notificationTopic("")
                .eventClick("")
                .notificationTypeCode(NotificationTypeCode.NTTP006)//디자이너수정
                .notificationTitle("알림센터_디자이너")
                .notificationContent("예약 취소됨")
                .receiverUid(request.getDesignerUid())
                .designerName(request.getDesignerName())
                .appointmentId(request.getAppointmentId())
                .appointmentAt(LocalDateTime.now())
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        int insertNotiCenterResultCustomer = notificationService.insertNotificationCenter(notificationInsertCenterRequestDtoCustomer);
        int insertNotiCenterResultDesigner = notificationService.insertNotificationCenter(notificationInsertCenterRequestDtoDesigner);

        if (insertNotiCenterResultCustomer == 0 || insertNotiCenterResultDesigner == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }
        //채팅 보내기
        ChatInsertRequestDto chatInsertRequestDtoCustomer = ChatInsertRequestDto.builder()
                .writeUid(request.getCustomerUid())
                .receiverId(request.getDesignerUid())
                .chatMessageContentTypeCode(ChatMessageContentTypeCode.CMCT001) //일반
                .chatMessageTypeCode(ChatMessageTypeCode.CMTP001) // 텍스트
                .chatMessageContent("예약을 취소하였습니다.")
                .workAt(LocalDateTime.now())
                .workId(request.getCustomerUid())
                .build();

        ChatInsertRequestDto chatInsertRequestDtoDesigner = ChatInsertRequestDto.builder()
                .writeUid(request.getDesignerUid())
                .receiverId(request.getCustomerUid())
                .chatMessageContentTypeCode(ChatMessageContentTypeCode.CMCT001) //일반
                .chatMessageTypeCode(ChatMessageTypeCode.CMTP001) // 텍스트
                .chatMessageContent("시술일시 : " + request.getTreatmentStartAt() + " 취소되었습니다.")
                .workAt(LocalDateTime.now())
                .workId(request.getDesignerUid())
                .build();

        int chatResult = 0;
        if (request.getAppointmentStartTypeCode() == APSR003) {
            chatResult = chatService.sendChat(chatInsertRequestDtoCustomer);
        } else {
            chatResult = chatService.sendChat(chatInsertRequestDtoDesigner);
        }

        if (chatResult == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }
    }

    public void insertAppointmentSign(AppointmentSignInsertRequestDto request) {
        request.setWorkAt(LocalDateTime.now());

        int signInsertResult = appointmentMapper.insertAppointmentSign(request);

        if (signInsertResult == 0) {
            throw new NotificationException(NotificationException.Reason.INVALID_ID);
        }
    }
}
