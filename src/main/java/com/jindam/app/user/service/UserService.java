package com.jindam.app.user.service;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.jindam.app.user.exception.UserException;
import com.jindam.app.user.exception.UserException.Reason;
import com.jindam.app.user.mapper.UserMapper;
import com.jindam.app.user.model.DailyScheduleResponseDto;
import com.jindam.app.user.model.MonthlyScheduleResponseDto;
import com.jindam.app.user.model.ScheduleRequestDto;
import com.jindam.app.user.model.UserDeleteRequestDto;
import com.jindam.app.user.model.UserDetailRequestDto;
import com.jindam.app.user.model.UserDetailResponseDto;
import com.jindam.app.user.model.UserFavoriteDetailRequestDto;
import com.jindam.app.user.model.UserFavoriteDetailResponseDto;
import com.jindam.app.user.model.UserFavoriteUpdateRequestDto;
import com.jindam.app.user.model.UserInsertRequestDto;
import com.jindam.app.user.model.UserUpdateRequestDto;
import com.jindam.base.base.PagingService;
import com.jindam.base.dto.PagingResponseDto;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
// @Transactional(readOnly = true)
@Transactional
@Slf4j
public class UserService extends PagingService {
    private final UserMapper userMapper;

    /**
     *
     * @return 사용자 정보
     */
    public UserDetailResponseDto selectOneUser(UserDetailRequestDto request) {
        // shopDetail은 MyBatis resultMap (userDetailWithShopMap) 에서
        // rep_shop LEFT JOIN으로 한번에 조회·매핑됨
        UserDetailResponseDto result = userMapper.selectOneUserByUid(request);

        if (result == null) {
            return null;
        }

        // 디자이너 후기 카운트 조회
        if (result.getUid() != null) {
            List<Map<String, Object>> reviewRows = userMapper.selectDesignerReviewCounts(result.getUid());
            if (reviewRows != null && !reviewRows.isEmpty()) {
                Map<String, Object> reviewCountMap = new LinkedHashMap<>();
                for (Map<String, Object> row : reviewRows) {
                    String typeCode = (String) row.get("reviewTypeCode");
                    Object count = row.get("reviewCount");
                    if (typeCode != null && count != null) {
                        // Flutter front 형식으로 변환: "friendlyService" -> "ReviewType.friendlyService"
                        String frontKey = "ReviewType." + typeCode;
                        reviewCountMap.put(frontKey, ((Number) count).intValue());
                    }
                }
                if (!reviewCountMap.isEmpty()) {
                    result.setReviewCount(reviewCountMap);
                }
            }
        }

        return result;
    }

    /**
     * @param UserDetailRequestDto uid
     * @return 사용자 정보
     */

    /**
     * @return int count
     */
    public UserDetailResponseDto insertUser(UserInsertRequestDto request) {
        int result;
        UserDetailRequestDto detailRequestDto = UserDetailRequestDto.from(request);

        // 1. 활성(delete_yn='N') 유저 UID 중복 체크
        UserDetailResponseDto dupByUid = userMapper.selectOneUserByUid(detailRequestDto);
        if (dupByUid != null) {
            throw new UserException(Reason.DUPLICATE_ID);
        }

        // 2. 탈퇴(delete_yn='Y') 유저 재가입 체크 (동일 UID)
        UserDetailResponseDto deletedUser = userMapper.selectDeletedUserByUid(detailRequestDto);
        if (deletedUser != null) {
            // 재활성화: 데이터 초기화 + delete_yn='N'
            userMapper.reactivateUser(request);
            return userMapper.selectOneUserByUid(detailRequestDto);
        }

        // 3. 활성(delete_yn='N') 유저 이메일+가입유형 중복 체크
        UserDetailResponseDto dupByEmail = userMapper.selectOneUserByEmailAndUserJoinTypeCode(detailRequestDto);
        if (dupByEmail != null) {
            throw new UserException(Reason.DUPLICATE_ID);
        }

        // 4. 순수 신규 가입
        result = userMapper.insertUser(request);
        UserDetailResponseDto userDto = new UserDetailResponseDto();
        if (result > 0) {
            userDto = userMapper.selectOneUserByUid(detailRequestDto);
        }

        return userDto;
    }

    public UserDetailResponseDto updateUser(UserUpdateRequestDto request) {

        // request.setUpdateId(request.getUid());
        // request.setUpdateAt(LocalDateTime.now());
        int result = userMapper.updateUser(request);

        if (result == 0) { // 유정 수정 처리 실패
            throw new UserException(UserException.Reason.INVALID_ID);
        }
        UserDetailRequestDto detailRequestDto = UserDetailRequestDto.from(request);
        UserDetailResponseDto success = userMapper.selectOneUserByUid(detailRequestDto);
        return success;

    }

    public UserDetailResponseDto updateDesignerProfile(UserUpdateRequestDto request) {

        int result = userMapper.updateDesignerProfile(request);

        if (result == 0) { // 유정 수정 처리 실패
            throw new UserException(UserException.Reason.INVALID_ID);
        }
        UserDetailRequestDto detailRequestDto = UserDetailRequestDto.from(request);
        UserDetailResponseDto success = userMapper.selectOneUserByUid(detailRequestDto);
        return success;

    }

    /**
     * 회원 탈퇴 — 하나의 트랜잭션에서 유저 + 연관 데이터 일괄 soft-delete
     */
    public void deleteUser(UserDeleteRequestDto request) {
        int result = userMapper.deleteUser(request);

        if (result == 0) {
            throw new UserException(UserException.Reason.INVALID_ID);
        }

        String uid = request.getUid();

        // 예약 일괄 삭제
        userMapper.deleteAppointmentsByUid(uid);
        // 알림 일괄 삭제
        userMapper.deleteNotificationCentersByUid(uid);
        // 매장 일괄 삭제
        userMapper.deleteShopsByUid(uid);
    }

    /**
     * @param request 사용자ID
     * @return 사용자 정보
     */
    public UserDetailResponseDto loginUser(UserDetailRequestDto request) {
        UserDetailResponseDto param = userMapper.loginUserByUid(request);

        // 데이터 없으면
        if (param != null) {
            throw new UserException(Reason.INVALID_ID);
        }
        // 데이터있으면 최종로그인일시 업데이트
        UserUpdateRequestDto userUpdateRequestDto = new UserUpdateRequestDto();
        userUpdateRequestDto.setUid(request.getUid());
        userUpdateRequestDto.setLastLoginAt(LocalDateTime.now());
        userMapper.updateLastLoginByUid(userUpdateRequestDto);

        return param;
    }

    public PagingResponseDto<UserDetailResponseDto> selectListDesignerPaging(UserDetailRequestDto request) {

        PagingResponseDto<UserDetailResponseDto> pagingResult = findData(userMapper, "selectListDesignerPaging", request);

        return pagingResult;
    }

    /**
     * 즐겨찾기
     *
     */
    public int updateFavoriteUser(UserFavoriteUpdateRequestDto request) {
        int result = 0;

        UserFavoriteDetailRequestDto checkDto = UserFavoriteDetailRequestDto.builder()
            .uid(request.getUid())
            .bookmarkTargetUserId(request.getBookmarkTargetUserId())
            .build();

        UserFavoriteDetailResponseDto checkResult;
        checkResult = userMapper.selectUserFavoriteCheck(checkDto);
        if (checkResult == null) {
            // 없으면 인서트
            int insertResult = userMapper.insertFavoriteUser(request);
            if (insertResult <= 0) {
                throw new UserException(UserException.Reason.INVALID_ID);
            }
            result = 1;
        } else {
            result = userMapper.updateFavoriteUser(request);

            if (result <= 0) {
                throw new UserException(UserException.Reason.INVALID_ID);
            }
        }

        return result;
    }

    public PagingResponseDto<UserFavoriteDetailResponseDto> selectUserFavoriteByUidPaging(UserFavoriteDetailRequestDto request) {

        PagingResponseDto<UserFavoriteDetailResponseDto> pagingResult = findData(userMapper, "selectUserFavoriteByUidPaging", request);

        return pagingResult;
    }

    /**
     * 디자이너 스케줄 조회 (월별, 일별)
     */

    public List<MonthlyScheduleResponseDto> selectMonthlySchedule(ScheduleRequestDto request) {
        List<MonthlyScheduleResponseDto> calenderList;
        calenderList = userMapper.selectMonthlySchedule(request);
        return calenderList;
    }

    public List<DailyScheduleResponseDto> selectDailySchedule(ScheduleRequestDto request) {
        List<DailyScheduleResponseDto> dailyScheduleList;
        dailyScheduleList = userMapper.selectDailySchedule(request);
        return dailyScheduleList;
    }
}
