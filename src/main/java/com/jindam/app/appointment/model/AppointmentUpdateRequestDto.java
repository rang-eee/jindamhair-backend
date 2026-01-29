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
import java.util.Objects;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "예약 상세 수정 요청 모델")
public class AppointmentUpdateRequestDto {
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

    @Schema(description = "작업일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime workAt;

    @Schema(description = "작업자 ID", example = "123")
    private String workId;

    @Schema(description = "예약 시술 목록", example = "123")
    List<AppointmentTreatmentInsertRequestDto> treatmentList;

    /**
     * AppointmentInsertRequestDto -> AppointmentUpdateRequestDto 변환 사용법: AppointmentUpdateRequestDto updateDto = AppointmentUpdateRequestDto.from(insertDto);
     */
    public static AppointmentUpdateRequestDto from(AppointmentInsertRequestDto dto) {

        // 필수값인 ID가 없으면 에러 발생 (안전장치)
        Objects.requireNonNull(dto.getAppointmentId(), "AppointmentInsertRequestDto의 appointmentId는 null일 수 없습니다.");

        return AppointmentUpdateRequestDto.builder()
                // 1. 식별자 정보
                .appointmentId(dto.getAppointmentId())
                .customerUid(dto.getCustomerUid())
                .designerUid(dto.getDesignerUid())
                .shopId(dto.getShopId())

                // 2. 상태 및 결제 정보
                .appointmentStatusCode(dto.getAppointmentStatusCode())
                .appointmentStartTypeCode(dto.getAppointmentStartTypeCode())
                .paymentMethodCode(dto.getPaymentMethodCode())

                // 3. 금액 정보
                .totalAmount(dto.getTotalAmount())
                .appointmentAmount(dto.getAppointmentAmount())

                // 4. 일정 정보
                .treatmentStartAt(dto.getTreatmentStartAt())
                .treatmentEndAt(dto.getTreatmentEndAt())

                // 5. 내용 및 후기
                .appointmentContent(dto.getAppointmentContent())
                .cancelReasonContent(dto.getCancelReasonContent())
                .reviewId(dto.getReviewId())

                // 6. 시스템 관리 정보 (업데이트 시점 기록용)
                //                .updateId(dto.getUpdateId()) // 혹은 dto.getUid()
                //                .updateAt(dto.getUpdateAt()) // 혹은 LocalDateTime.now()
                //                .deleteYn(dto.getDeleteYn())
                //                .deleteAt(dto.getDeleteAt())
                //                .deleteId(dto.getDeleteId())

                /* [체크] UpdateDto에 없는 필드(단순 조인용 이름 등)는 제외됨
                 * customerName, shopName, createAt 등은 보통 수정 대상이 아니므로 뺍니다.
                 */.build();
    }
}
