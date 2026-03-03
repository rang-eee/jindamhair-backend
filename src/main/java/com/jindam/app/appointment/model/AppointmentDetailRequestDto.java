package com.jindam.app.appointment.model;

import com.jindam.base.code.AppointmentStartTypeCode;
import com.jindam.base.code.AppointmentStatusCode;
import com.jindam.base.code.PaymentMethodCode;
import com.jindam.base.dto.PagingRequestDto;
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
@Schema(description = " 요청 모델")
public class AppointmentDetailRequestDto extends PagingRequestDto {
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

    @Schema(description = "조회할 예약 상태 코드 목록")
    private List<AppointmentStatusCode> includeAppointmentStatusCodes;

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

    @Schema(description = "작업 일시", example = "2024-11-11T17:04:56.082147")
    private LocalDateTime workAt;

    @Schema(description = "생성 ID", example = "123")
    private String createId;

    /**
     * AppointmentUpdateRequestDto를 AppointmentDetailRequestDto로 변환합니다.
     */
    public static AppointmentDetailRequestDto from(AppointmentUpdateRequestDto dto) {

        // uid null 체크 (괄호 오타 수정됨)
        Objects.requireNonNull(dto.getAppointmentId(), "AppointmentUpdateRequestDto appointmentId는 null일 수 없습니다.");

        return AppointmentDetailRequestDto.builder()
            // 1. 기본 식별자
            .appointmentId(dto.getAppointmentId())
            .customerUid(dto.getCustomerUid())
            .designerUid(dto.getDesignerUid())
            .shopId(dto.getShopId())

            // 2. 상태 및 코드 정보
            .appointmentStatusCode(dto.getAppointmentStatusCode())
            .appointmentStartTypeCode(dto.getAppointmentStartTypeCode())
            .paymentMethodCode(dto.getPaymentMethodCode())

            // 3. 금액 정보
            .totalAmount(dto.getTotalAmount())
            .appointmentAmount(dto.getAppointmentAmount())

            // 4. 일시 정보
            .treatmentStartAt(dto.getTreatmentStartAt())
            .treatmentEndAt(dto.getTreatmentEndAt())

            // 5. 내용 정보
            .appointmentContent(dto.getAppointmentContent())
            .cancelReasonContent(dto.getCancelReasonContent())
            .reviewId(dto.getReviewId())

            /*
             * * [주의] 아래 필드들은 UpdateRequestDto에 없을 가능성이 높습니다. 없는 필드는 삭제하거나 null로 처리하세요.
             */

            // 6. 고객/디자이너/샵 상세 정보 (Join 데이터)
            .customerName(dto.getCustomerName())
            .customerNickname(dto.getCustomerNickname())
            .customerContact(dto.getCustomerContact())
            .designerName(dto.getDesignerName())
            .designerNickname(dto.getDesignerNickname())
            .designerContact(dto.getDesignerContact())
            .shopName(dto.getShopName())
            .shopAddr(dto.getShopAddr())

            .build();
    }

    /**
     * AppointmentInsertRequestDto AppointmentDetailRequestDto로 변환합니다.
     */
    public static AppointmentDetailRequestDto from(AppointmentInsertRequestDto dto) {

        // uid null 체크 (괄호 오타 수정됨)
        Objects.requireNonNull(dto.getAppointmentId(), "AppointmentInsertRequestDto appointmentId는 null일 수 없습니다.");

        return AppointmentDetailRequestDto.builder()
            // 1. 기본 식별자
            .appointmentId(dto.getAppointmentId())
            .customerUid(dto.getCustomerUid())
            .designerUid(dto.getDesignerUid())
            .shopId(dto.getShopId())

            // 2. 상태 및 코드 정보
            .appointmentStatusCode(dto.getAppointmentStatusCode())
            .appointmentStartTypeCode(dto.getAppointmentStartTypeCode())
            .paymentMethodCode(dto.getPaymentMethodCode())

            // 3. 금액 정보
            .totalAmount(dto.getTotalAmount())
            .appointmentAmount(dto.getAppointmentAmount())

            // 4. 일시 정보
            .treatmentStartAt(dto.getTreatmentStartAt())
            .treatmentEndAt(dto.getTreatmentEndAt())

            // 5. 내용 정보
            .appointmentContent(dto.getAppointmentContent())
            .cancelReasonContent(dto.getCancelReasonContent())
            .reviewId(dto.getReviewId())

            /*
             * * [주의] 아래 필드들은 UpdateRequestDto에 없을 가능성이 높습니다. 없는 필드는 삭제하거나 null로 처리하세요.
             */

            // 6. 고객/디자이너/샵 상세 정보 (Join 데이터)
            .customerName(dto.getCustomerName())
            .customerNickname(dto.getCustomerNickname())
            .customerContact(dto.getCustomerContact())
            .designerName(dto.getDesignerName())
            .designerNickname(dto.getDesignerNickname())
            .designerContact(dto.getDesignerContact())
            .shopName(dto.getShopName())
            .shopAddr(dto.getShopAddr())

            .build();
    }

    /**
     * AppointmentDeleteRequestDto AppointmentDetailRequestDto로 변환합니다.
     */
    public static AppointmentDetailRequestDto from(AppointmentDeleteRequestDto dto) {

        // uid null 체크 (괄호 오타 수정됨)
        Objects.requireNonNull(dto.getAppointmentId(), "AppointmentDeleteRequestDto appointmentId는 null일 수 없습니다.");

        return AppointmentDetailRequestDto.builder()
            // 1. 기본 식별자
            .appointmentId(dto.getAppointmentId())
            .customerUid(dto.getCustomerUid())
            .designerUid(dto.getDesignerUid())
            .shopId(dto.getShopId())

            // 2. 상태 및 코드 정보
            .appointmentStatusCode(dto.getAppointmentStatusCode())
            .appointmentStartTypeCode(dto.getAppointmentStartTypeCode())
            .paymentMethodCode(dto.getPaymentMethodCode())

            // 3. 금액 정보
            .totalAmount(dto.getTotalAmount())
            .appointmentAmount(dto.getAppointmentAmount())

            // 4. 일시 정보
            .treatmentStartAt(dto.getTreatmentStartAt())
            .treatmentEndAt(dto.getTreatmentEndAt())

            // 5. 내용 정보
            .appointmentContent(dto.getAppointmentContent())
            .cancelReasonContent(dto.getCancelReasonContent())
            .reviewId(dto.getReviewId())

            /*
             * * [주의] 아래 필드들은 UpdateRequestDto에 없을 가능성이 높습니다. 없는 필드는 삭제하거나 null로 처리하세요.
             */

            // 6. 고객/디자이너/샵 상세 정보 (Join 데이터)
            .customerName(dto.getCustomerName())
            .customerNickname(dto.getCustomerNickname())
            .customerContact(dto.getCustomerContact())
            .designerName(dto.getDesignerName())
            .designerNickname(dto.getDesignerNickname())
            .designerContact(dto.getDesignerContact())
            .shopName(dto.getShopName())
            .shopAddr(dto.getShopAddr())

            .build();
    }

}
