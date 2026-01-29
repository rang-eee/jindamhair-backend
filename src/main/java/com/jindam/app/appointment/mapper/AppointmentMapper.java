package com.jindam.app.appointment.mapper;

import com.jindam.app.appointment.model.*;

import java.util.List;

/**
 * ExampleMapper 인터페이스
 *
 * <p>
 * 데이터베이스와 상호작용하는 MyBatis Mapper로, Example 관련 CRUD 및 페이징 처리를 위한 메서드를 정의합니다.
 * </p>
 */
public interface AppointmentMapper {
    AppointmentDetailResponseDto selectAppointmentById(AppointmentDetailRequestDto request);

    /**
     * 목록 페이징 처리 후 조회
     */
    List<AppointmentDetailResponseDto> selectAppointmentByCustIdPaging(AppointmentDetailRequestDto request);

    /**
     * 목록 카운트 조회
     */
    int selectAppointmentByCustIdCount(AppointmentDetailRequestDto request);

    List<AppointmentDetailResponseDto> selectAppointmentByEmail(AppointmentEmailRequestDto request);

    int insertAppointment(AppointmentInsertRequestDto request);

    int updateAppointment(AppointmentUpdateRequestDto request);

    int deleteAppointment(AppointmentDeleteRequestDto request);

    int insertAppointmentTreatment(AppointmentTreatmentInsertRequestDto request);

}
