package com.jindam.app.user.userCommon.mapper;

import com.jindam.app.user.userCommon.model.UserDetailResponseDto;

/**
 * ExampleMapper 인터페이스
 *
 * <p>
 * 데이터베이스와 상호작용하는 MyBatis Mapper로, Example 관련 CRUD 및 페이징 처리를 위한 메서드를 정의합니다.
 * </p>
 */
public interface LoginMapper {
    /**
     * 사용자 로그인 처리
     *
     */
    UserDetailResponseDto loginUserByUid(String uid);

    int updateLastLoginByUid(String uid);
}
