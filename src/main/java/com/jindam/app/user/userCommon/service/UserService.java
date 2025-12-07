package com.jindam.app.user.userCommon.service;

import com.jindam.app.example.exception.ExampleException;
import com.jindam.app.example.exception.ExampleException.Reason;
import com.jindam.app.user.userCommon.mapper.UserMapper;
import com.jindam.app.user.userCommon.model.*;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class UserService extends PagingService {
    private final UserMapper userMapper;

    /**
     * @param UserDetailRequestDto uid
     * @return 사용자 정보
     */
    public UserDetailResponseDto selectOneUser(UserDetailRequestDto request) {
        String uid = request.getUid();
        UserDetailResponseDto result = userMapper.selectOneUserByUid(uid);
        return result;
    }

    /**
     * @param UserInsertRequestDto request
     * @retunr int count
     */
    public UserDetailResponseDto insertUser(UserInsertRequestDto request) {
        String uid = request.getUid();
        int result;

        int dup = userMapper.insertUser(request);

        if (dup != 1) {
            throw new ExampleException(Reason.DUPLICATE_ID);
        } else {
            result = userMapper.insertUser(request);
        }

        if (result > 0) {
            UserDetailResponseDto success = userMapper.selectOneUserByUid(uid);
            return success;
        } else {
            return null;
        }
    }

    public UserDetailResponseDto updateUser(UserUpdateRequestDto request) {
        String uid = request.getUid();

        int result = userMapper.updateUser(request);

        if (result > 0) {
            UserDetailResponseDto success = userMapper.selectOneUserByUid(uid);
            return success;
        } else {
            return null;
        }
    }

    public UserDetailResponseDto deleteUser(UserDeleteRequestDto request) {
        String uid = request.getUid();
        int result = userMapper.deleteUser(uid);

        if (result > 0) {
            UserDetailResponseDto success = userMapper.selectOneUserByUid(uid);
            return success;
        } else {
            return null;
        }
    }

}
