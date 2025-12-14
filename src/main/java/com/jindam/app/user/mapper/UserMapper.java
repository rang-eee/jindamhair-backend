package com.jindam.app.user.mapper;

import com.jindam.app.user.model.*;

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

    /* 유저 생성 */
    int insertUser(UserInsertRequestDto request);

    /* 유저 업데이트 */
    int updateUser(UserUpdateRequestDto request);

    /* 유저 딜리트 (사용여부 N 으로 업데이트)*/
    int deleteUser(UserDeleteRequestDto request);

    /**
     * 사용자 로그인 처리
     *
     */
    UserDetailResponseDto loginUserByUid(UserDetailRequestDto request);

    int updateLastLoginByUid(UserUpdateRequestDto request);

}
