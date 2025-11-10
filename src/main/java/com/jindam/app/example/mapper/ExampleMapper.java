package com.jindam.app.example.mapper;

import java.util.List;

import com.jindam.app.example.model.ExampleDetailResponseDto;
import com.jindam.app.example.model.ExampleListRequestDto;
import com.jindam.app.example.model.ExampleModifyRequestDto;
import com.jindam.app.example.model.ExampleRegisterRequestDto;

/**
 * ExampleMapper 인터페이스
 * 
 * <p>
 * 데이터베이스와 상호작용하는 MyBatis Mapper로, Example 관련 CRUD 및 페이징 처리를 위한 메서드를 정의합니다.
 * </p>
 */
public interface ExampleMapper {

    /**
     * 페이징 조건에 따라 Example 데이터를 조회합니다.
     *
     * @param request 페이징 요청 객체
     * @return 페이징 조건에 맞는 Example 데이터 목록
     */
    List<ExampleDetailResponseDto> selectByCriteriaPaging(ExampleListRequestDto request);

    /**
     * 페이징 조건에 따른 전체 데이터 건수를 조회합니다.
     *
     * @param request 페이징 요청 객체
     * @return 페이징 조건에 해당하는 전체 데이터 건수
     */
    Integer selectByCriteriaPagingCount(ExampleListRequestDto request);

    /**
     * 특정 조건에 따라 Example 데이터를 조회합니다.
     *
     * @param request 조건 요청 객체
     * @return 조건에 맞는 Example 데이터 목록
     */
    List<ExampleDetailResponseDto> selectByCriteria(ExampleListRequestDto request);

    /**
     * 사용자 ID에 해당하는 Example 데이터를 조회합니다.
     *
     * @param userId 사용자 ID
     * @return 사용자 ID에 해당하는 Example 데이터
     */
    ExampleDetailResponseDto selectById(String userId);

    /**
     * 사용자 ID를 입력받고 DB에 동일한 사용자 ID가 존재하는지 검사합니다.
     *
     * @param userId 사용하고자 하는 사용자 ID
     * @return 사용자 ID가 존재하면 true, 존재하지 않으면 false
     */
    boolean existsUserId(String userId);

    /**
     * Example 데이터를 등록합니다.
     *
     * @param request 등록 요청 객체
     * @return 등록된 데이터 수 (보통 1)
     */
    int createExample(ExampleRegisterRequestDto request);

    /**
     * Example 데이터를 수정합니다.
     *
     * @param request 수정 요청 객체
     * @return 수정된 데이터 수
     */
    int modifyExample(ExampleModifyRequestDto request);

    /**
     * 사용자 ID에 해당하는 Example 데이터를 삭제합니다.
     *
     * @param userId 삭제할 사용자 ID
     * @return 삭제된 데이터 수
     */
    int removeExample(String userId);
}
