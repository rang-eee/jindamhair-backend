package com.jindam.app.user.userCommon.mapper;

import com.jindam.app.user.userCommon.model.UserDetailResponseDto;
import com.jindam.app.user.userCommon.model.UserInsertRequestDto;
import com.jindam.app.user.userCommon.model.UserUpdateRequestDto;

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
    UserDetailResponseDto selectOneUserByUid(String uid);

    /* 유저 생성 */
    int insertUser(UserInsertRequestDto request);

    /* 유저 업데이트 */
    int updateUser(UserUpdateRequestDto request);

    /* 유저 딜리트 (사용여부 N 으로 업데이트)*/
    int deleteUser(String uid);

}
