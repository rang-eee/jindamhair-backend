package com.jindam.app.appointment.service;

import com.jindam.app.appointment.exception.AppointmentException;
import com.jindam.app.appointment.mapper.AppointmentMapper;
import com.jindam.app.appointment.model.*;
import com.jindam.app.chat.service.ChatService;
import com.jindam.app.notification.service.NotificationService;
import com.jindam.base.code.AppointmentStatusCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class AppointmentService {
    private final AppointmentMapper appointmentMapper;
    private final NotificationService notificationService;
    private final ChatService chatService;

    public AppointmentDetailResponseDto selectAppointmentById(AppointmentDetailRequestDto request) {
        AppointmentDetailResponseDto result;
        result = appointmentMapper.selectAppointmentById(request);

        return result;
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
        tt = appointmentMapper.selectAppointmentById(insertRequestDto);
        String autoYn = tt.getDesignerDesignerAppointmentAutomaticConfirmYn();

        if (autoYn.equals("Y")) {
            //예약상태 업데이트
            AppointmentUpdateRequestDto updateDto = AppointmentUpdateRequestDto.builder()
                    .appointmentId(request.getAppointmentId())
                    .appointmentStatusCode(AppointmentStatusCode.APST005)
                    //.workAt(LocalDateTime.now())
                    //.workId(request.ge)
                    .build();

            updateDto.setAppointmentStatusCode(AppointmentStatusCode.APST005);//예약완료
            int updateResult = appointmentMapper.updateAppointment(updateDto);

            if (updateResult == 0) { // 예약상태 변경 실패
                throw new AppointmentException(AppointmentException.Reason.INVALID_ID);
            }
            //알림센터 인서트
            //notificationService.insertNotification();
            //if (insertNotiReslut == 0){
            //   throw new NotificationException(AppointmentException.Reason.INVALID_ID);
            // }
            //푸쉬알림 테이블 인서트
            //notificationService.insertNotificationPush();
            //채팅 보내기
            //chatService.selectChatRoom();
            //if(chatRoomResult  != null) {
            //chatService.insertChat();
            // }

        } else {
            
        }

        AppointmentDetailResponseDto success = appointmentMapper.selectAppointmentById(insertRequestDto);
        return null;
    }

    public AppointmentDetailResponseDto updateAppointment(AppointmentUpdateRequestDto request) {

        int result;
        result = appointmentMapper.updateAppointment(request);

        if (result > 0) {
            AppointmentDetailRequestDto insertRequestDto = AppointmentDetailRequestDto.from(request);

            AppointmentDetailResponseDto success = appointmentMapper.selectAppointmentById(insertRequestDto);
            return success;
        } else {
            return null;
        }
    }

    public AppointmentDetailResponseDto deleteAppointment(AppointmentDeleteRequestDto request) {

        int result;
        result = appointmentMapper.deleteAppointment(request);

        if (result > 0) {
            AppointmentDetailRequestDto insertRequestDto = AppointmentDetailRequestDto.from(request);

            AppointmentDetailResponseDto success = appointmentMapper.selectAppointmentById(insertRequestDto);
            return success;
        } else {
            return null;
        }
    }

}
