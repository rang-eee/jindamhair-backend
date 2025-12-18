package com.jindam.app.user.service;

import com.jindam.app.user.exception.UserException;
import com.jindam.app.user.exception.UserException.Reason;
import com.jindam.app.user.mapper.UserMapper;
import com.jindam.app.user.model.*;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class UserService extends PagingService {
    private final UserMapper userMapper;

    /**
     *
     * @return 사용자 정보
     */
    public UserDetailResponseDto selectOneUser(UserDetailRequestDto request) {
        UserDetailResponseDto result = userMapper.selectOneUserByUid(request);
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

        if (dupByUid != null) {
            throw new UserException(Reason.DUPLICATE_ID);
        }

        UserDetailResponseDto dupByEmailJoinTypeCode = userMapper.selectOneUserByEmailAndUserJoinTypeCode(detailRequestDto);

        if (dupByEmailJoinTypeCode != null) {
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

        int result = userMapper.updateUser(request);

        if (result > 0) {
            UserDetailRequestDto detailRequestDto = UserDetailRequestDto.from(request);
            UserDetailResponseDto success = userMapper.selectOneUserByUid(detailRequestDto);
            return success;
        } else {
            return null;
        }
    }

    public UserDetailResponseDto deleteUser(UserDeleteRequestDto request) {
        int result = userMapper.deleteUser(request);

        if (result > 0) {
            UserDetailRequestDto detailRequestDto = UserDetailRequestDto.from(request);
            UserDetailResponseDto success = userMapper.selectOneUserByUid(detailRequestDto);
            return success;
        } else {
            return null;
        }
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

    //    public List<UserDetailResponseDto> selectListDesigner(UserDetailRequestDto request) {
    //        List<UserDetailResponseDto> result = userMapper.selectListDesigner(request);
    //        return result;
    //    }
}
