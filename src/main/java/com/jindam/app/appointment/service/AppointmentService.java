package com.jindam.app.appointment.service;

import com.jindam.app.appointment.mapper.AppointmentMapper;
import com.jindam.app.appointment.model.*;
import com.jindam.base.code.AppointmentStatusCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class AppointmentService {
    private final AppointmentMapper appointmentMapper;

    public AppointmentDetailResponseDto selectAppointmentById(AppointmentDetailRequestDto request) {
        AppointmentDetailResponseDto result;
        result = appointmentMapper.selectAppointmentById(request);

        return result;
    }

    public AppointmentDetailResponseDto insertAppointment(AppointmentInsertRequestDto request) {

        int result;
        result = appointmentMapper.insertAppointment(request);

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

        if (result > 0) { // 예약인서트 성공
            int resultInsertAppTreat;
            resultInsertAppTreat = appointmentMapper.insertAppointmentTreatment(request);
            AppointmentDetailRequestDto insertRequestDto = AppointmentDetailRequestDto.from(request);

            if (resultInsertAppTreat > 0) {//예약시술테이블 인서트 성공
                //예약 자동처리여부 확인
                AppointmentDetailResponseDto tt;
                tt = appointmentMapper.selectAppointmentById(insertRequestDto);
                String autoYn = tt.getDesignerDesignerAppointmentAutomaticConfirmYn();

                if (autoYn.equals("Y")) {
                    //예약상태 업데이트
                    AppointmentUpdateRequestDto updateDto = AppointmentUpdateRequestDto.from(request);
                    updateDto.setAppointmentStatusCode(AppointmentStatusCode.APST005);//예약완료
                    appointmentMapper.updateAppointment(updateDto);

                    //
                    //알림센터 인서트
                    //푸쉬알림 테이블 인서트
                    //채팅 보내기
                } else {

                }

            }

            AppointmentDetailResponseDto success = appointmentMapper.selectAppointmentById(insertRequestDto);
            return null;
        } else {
            return null;
        }
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
