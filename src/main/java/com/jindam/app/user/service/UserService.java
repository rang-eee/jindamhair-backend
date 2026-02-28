package com.jindam.app.user.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.jindam.app.shop.mapper.ShopMapper;
import com.jindam.app.shop.model.DesignerShopInsertRequestDto;
import com.jindam.app.shop.model.DesingerShopDetailResponseDto;
import com.jindam.app.user.exception.UserException;
import com.jindam.app.user.exception.UserException.Reason;
import com.jindam.app.user.mapper.UserMapper;
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
    private final ShopMapper shopMapper;

    /**
     *
     * @return 사용자 정보
     */
    public UserDetailResponseDto selectOneUser(UserDetailRequestDto request) {
        UserDetailResponseDto result = userMapper.selectOneUserByUid(request);

        // 매장 조회
        DesignerShopInsertRequestDto req = DesignerShopInsertRequestDto.builder()
            .uid(result.getUid())
            .build();
        List<DesingerShopDetailResponseDto> shopList = shopMapper.selectListShopById(req);

        DesingerShopDetailResponseDto repShop = shopList.stream()
            .filter(s -> "Y".equals(s.getRepresentativeYn()))
            .findFirst()
            .orElse(null); // 없으면 null
        result.setShopDetail(repShop);

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

        UserDetailResponseDto dupByUid = userMapper.selectOneUserByUid(detailRequestDto);

        if (dupByUid != null) { // 아이디 중복일경우
            throw new UserException(Reason.DUPLICATE_ID);
        }

        UserDetailResponseDto dupByEmailJoinTypeCode = userMapper.selectOneUserByEmailAndUserJoinTypeCode(detailRequestDto);

        if (dupByEmailJoinTypeCode != null) { // 이메일 가입유형 코드
            throw new UserException(Reason.DUPLICATE_ID);
        }

        result = userMapper.insertUser(request);
        UserDetailResponseDto userDto = new UserDetailResponseDto();
        if (result > 0) {
            userDto = userMapper.selectOneUserByUid(detailRequestDto);
        }

        // to-do 추전 디자이너 이메일이 있을경우 통계테이블 카운트 증가시키기 requset
        // 통계 dto 만들어서 업데이트 요청 던지기

        return userDto;
    }

    public UserDetailResponseDto updateUser(UserUpdateRequestDto request) {

        request.setUpdateAt(LocalDateTime.now());
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

    public UserDetailResponseDto deleteUser(UserDeleteRequestDto request) {
        int result = userMapper.deleteUser(request);

        if (result == 0) { // 유저 삭제 처리 실패
            throw new UserException(UserException.Reason.INVALID_ID);
        }
        UserDetailRequestDto detailRequestDto = UserDetailRequestDto.from(request);
        UserDetailResponseDto success = userMapper.selectOneUserByUid(detailRequestDto);
        return success;
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
        if (checkResult != null) {
            // 없으면 인서트
            int insertResult;
            insertResult = userMapper.insertFavoriteUser(request);
            if (insertResult >= 0) {
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
}
