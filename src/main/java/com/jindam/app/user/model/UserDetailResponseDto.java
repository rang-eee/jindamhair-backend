package com.jindam.app.user.model;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "사용자 상세 조회 응답 모델")
public class UserDetailResponseDto {

    @Schema(description = "유저 아이디", example = "KShJUkrtJrVdRKNXCNz4BT8oRyn1")
    private String uid;

    @Schema(description = "유저 이메일", example = "text@gmail.com")
    private String userEmail;

    @Schema(description = "유저 연락처", example = "010-1234-1234")
    private String userContact;

    @Schema(description = "유저 이름", example = "홍길동")
    private String userName;

    @Schema(description = "유저 별명", example = "아버지를 아버지라 부르지 못하고")
    private String userNickname;

    @Schema(description = "유저 상태 코드", example = "??")
    private String userStatusCode;

    @Schema(description = "유저 성별 코드", example = "female or male")
    private String userGenderCode;

    @Schema(description = "유저 agg 코드", example = "10 or 20 or 30 ,,,")
    private String userAggCode;

    @Schema(description = "유저 유형 코드", example = "designer or cusertomer")
    private String userTypeCode;

    @Schema(description = "유저 생년월일", example = "yyyymmdd")
    private String userBrdt;

    @Schema(description = "유저 가입 유형 코드", example = "google, apple, kakao")
    private String userJoinTypeCode;

    @Schema(description = "푸쉬 토큰", example = "??")
    private String pushToken;

    @Schema(description = "최종 로그인 일시", example = "yyyymmddHHMISS")
    private LocalDateTime lastLoginAt;

    @Schema(description = "디자이너 승인 상태 코드")
    private String designerApprStatusCode;

    @Schema(description = "디자이너 소개 내용")
    private String designerIntroduceContent;

    @Schema(description = "디자이너 태그")
    private String designerTag;

    @Schema(description = "디자이너 근무 상태 코드")
    private String designerWorkStatusCode;

    @Schema(description = "디자이너 오픈 요일 배열")
    private String designerOpenDayArr;

    @Schema(description = "디자이너 오픈 시간 배열")
    private String designerOpenTimeArr;

    @Schema(description = "디자이너 오프 시간 배열")
    private String designerCloseTimeArr;

    @Schema(description = "디자이너 자동예양 확정 여부")
    private String designerAppointmentAutomaticConfirmYn;

    @Schema(description = "디자이너 앱링크 URL")
    private String designerApplinkUrl;

    @Schema(description = "위치 주소")
    private String positionAddr;

    @Schema(description = "위치 위도")
    private String positionLatt;

    @Schema(description = "위치 경도")
    private String positionLngt;

    @Schema(description = "위치 거리")
    private String positionDistance;

    @Schema(description = "헤어샵 ID")
    private String shopId;

    @Schema(description = "헤어샵 명")
    private String shopName;

    @Schema(description = "헤어샵 주소")
    private String shopAddr;

    @Schema(description = "헤어샵 연락처")
    private String shopContact;

    @Schema(description = "디자이너 세부파일 사진 아이디")
    private String designerDetailPhotoFileId;

    @Schema(description = "생성 일시")
    private LocalDateTime createAt;

    @Schema(description = "생성자 ID")
    private String createId;

    @Schema(description = "수정 일시")
    private LocalDateTime updateAt;

    @Schema(description = "수정자 ID")
    private String updateId;

    @Schema(description = "삭제여부")
    private String deleteYn;

    @Schema(description = "삭제자 ID")
    private String deleteId;

    @Schema(description = "삭제 일시")
    private LocalDateTime deleteAt;

}
