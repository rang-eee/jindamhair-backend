package com.jindam.app.user.userCommon.service;

import com.jindam.app.user.userCommon.mapper.LoginMapper;
import com.jindam.app.user.userCommon.model.UserDetailRequestDto;
import com.jindam.app.user.userCommon.model.UserDetailResponseDto;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class LoginService extends PagingService {
    private final LoginMapper loginMapper;

    /**
     * @param UserDetailRequestDto uid
     * @return 사용자 정보
     */
    public UserDetailResponseDto loginUser(UserDetailRequestDto request) {
        String uid = request.getUid();
        UserDetailResponseDto param = loginMapper.loginUserByUid(uid);
        UserDetailResponseDto result = null;

        if (param.getUid()
                .equals(uid)) {
            int success = loginMapper.updateLastLoginByUid(uid);

            if (success == 1) {
                result = param;
            } else {
                // 로그인 예외처리를 뭘로해야되나..
                result = null;
            }
        }

        return result;
    }
}
