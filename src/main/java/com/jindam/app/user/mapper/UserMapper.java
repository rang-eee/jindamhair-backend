package com.jindam.app.user.mapper;

import com.jindam.app.user.model.*;

import java.util.List;
import java.util.Map;

/**
 * ExampleMapper 인터페이스
 *
 * <p>
 * 데이터베이스와 상호작용하는 MyBatis Mapper로, Example 관련 CRUD 및 페이징 처리를 위한 메서드를 정의합니다.
 * </p>
 */
public interface UserMapper {
    /**
     * 사용자 조회
     */
    UserDetailResponseDto selectOneUserByUid(UserDetailRequestDto request);

    /**
     * 사용자 조회 이메일, 가입유형코드
     */
    UserDetailResponseDto selectOneUserByEmailAndUserJoinTypeCode(UserDetailRequestDto request);

    /** 탈퇴한 사용자 조회 — UID 기반 (재가입 확인용) */
    UserDetailResponseDto selectDeletedUserByUid(UserDetailRequestDto request);

    /* 유저 생성 */
    int insertUser(UserInsertRequestDto request);

    /* 탈퇴한 유저 재활성화 — UID 기반 (데이터 초기화) */
    int reactivateUser(UserInsertRequestDto request);

    /* 유저 업데이트 */
    int updateUser(UserUpdateRequestDto request);

    /* 디자이너 프로필 업데이트 (PUT) */
    int updateDesignerProfile(UserUpdateRequestDto request);

    /* 유저 딜리트 (사용여부 N 으로 업데이트) */
    int deleteUser(UserDeleteRequestDto request);

    /* 회원 탈퇴 일괄 삭제 */
    int deleteAppointmentsByUid(@org.apache.ibatis.annotations.Param("uid") String uid);

    int deleteNotificationCentersByUid(@org.apache.ibatis.annotations.Param("uid") String uid);

    int deleteShopsByUid(@org.apache.ibatis.annotations.Param("uid") String uid);

    /**
     * 사용자 로그인 처리
     *
     */
    UserDetailResponseDto loginUserByUid(UserDetailRequestDto request);

    int updateLastLoginByUid(UserUpdateRequestDto request);

    /**
     * 디자이너 목록 페이징 처리 후 조회
     */
    List<UserDetailResponseDto> selectListDesignerPaging(UserDetailRequestDto request);

    /**
     * 디자이너 목록 카운트 조회
     */
    int selectListDesignerPagingCount(UserDetailRequestDto request);

    /**
     * 디자이너 즐겨찾기
     */
    UserFavoriteDetailResponseDto selectUserFavoriteCheck(UserFavoriteDetailRequestDto request);

    int updateFavoriteUser(UserFavoriteUpdateRequestDto request);

    int insertFavoriteUser(UserFavoriteUpdateRequestDto request);

    /**
     * 목록 페이징 처리 후 조회
     */
    List<UserFavoriteDetailResponseDto> selectUserFavoriteByUidPaging(UserFavoriteDetailRequestDto request);

    /**
     * 목록 카운트 조회
     */
    int selectUserFavoriteByUidPagingCount(UserFavoriteDetailRequestDto request);

    /**
     * 디자이너 후기 카운트 조회 (tb_designer_review)
     */
    List<Map<String, Object>> selectDesignerReviewCounts(String uid);

    /**
     * 디자이너 스케줄 조회
     */
    List<MonthlyScheduleResponseDto> selectMonthlySchedule(ScheduleRequestDto request);

    List<DailyScheduleResponseDto> selectDailySchedule(ScheduleRequestDto request);
}
