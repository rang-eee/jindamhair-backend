package com.jindam.app.appointment.model;

import com.jindam.base.code.AppointmentStartTypeCode;
import com.jindam.base.code.AppointmentStatusCode;
import com.jindam.base.code.PaymentMethodCode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "예약 상세 조회 요청 모델")
public class AppointmentDeleteRequestDto {
    @Schema(description = "예약 ID", example = "123")
    private String appointmentId;

    @Schema(description = "고객 사용자ID", example = "123")
    private String customerUid;

    @Schema(description = "디자이너 사용자ID", example = "123")
    private String designerUid;

    @Schema(description = "헤어샵 ID", example = "123")
    private String shopId;

    @Schema(description = "예약 상태 코드", example = "123")
    private AppointmentStatusCode appointmentStatusCode;

    @Schema(description = "예약 시작 유형 코드", example = "123")
    private AppointmentStartTypeCode appointmentStartTypeCode;

    @Schema(description = "총 금액", example = "123")
    private String totalAmount;

    @Schema(description = "예약 금액", example = "123")
    private String appointmentAmount;

    @Schema(description = "시술 시작 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime treatmentStartAt;

    @Schema(description = "시술 종료 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime treatmentEndAt;

    @Schema(description = "결제 방법 코드", example = "123")
    private PaymentMethodCode paymentMethodCode;

    @Schema(description = "예약 내용", example = "123")
    private String appointmentContent;

    @Schema(description = "취소 사유 내용", example = "123")
    private String cancelReasonContent;

    @Schema(description = "후기 ID", example = "123")
    private String reviewId;

    @Schema(description = "고객 명", example = "123")
    private String customerName;

    @Schema(description = "고객 닉네임", example = "123")
    private String customerNickname;

    @Schema(description = "고객 연락처", example = "123")
    private String customerContact;

    @Schema(description = "디자이너 명", example = "123")
    private String designerName;

    @Schema(description = "디자이너 닉네임", example = "123")
    private String designerNickname;

    @Schema(description = "디자이너 연락처", example = "123")
    private String designerContact;

    @Schema(description = "헤어샵 명", example = "123")
    private String shopName;

    @Schema(description = "헤어샵 주소", example = "123")
    private String shopAddr;

    @Schema(description = "예약 시술 목록", example = "123")
    List<AppointmentTreatmentInsertRequestDto> treatmentList;

    @Schema(description = "작업 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime createAt;

    @Schema(description = "작업자 ID", example = "123")
    private String createId;
}
