package com.jindam.app.example.service;

import java.util.Arrays;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.jindam.app.example.exception.ExampleException;
import com.jindam.app.example.mapper.ExampleMapper;
import com.jindam.app.example.model.ExampleDetailResponseDto;
import com.jindam.app.example.model.ExampleListRequestDto;
import com.jindam.app.example.model.ExampleListResponseDto;
import com.jindam.app.example.model.ExampleModifyRequestDto;
import com.jindam.app.example.model.ExampleRegisterRequestDto;
import com.jindam.base.base.HistoryAppendService;
import com.jindam.base.base.HistoryAppendService.HistoryType;
import com.jindam.base.base.PagingService;
import com.jindam.base.dto.PagingResponseDto;
import com.jindam.base.message.Message;
import com.jindam.util.StringUtils;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class ExampleService extends PagingService {

    private final ExampleMapper exampleMapper; // tqms

    private final HistoryAppendService historyAppendService;

    /**
     * 주어진 검색 조건(request) 및 페이징을 기반으로 데이터를 조회합니다.
     *
     * @param request 검색 조건을 포함하는 요청 객체
     * @return 검색 조건에 부합하는 데이터 목록
     * @throws ExampleException 유효하지 않은 검색 타입인 경우
     */
    public PagingResponseDto<ExampleListResponseDto> findByCriteriaPaging(ExampleListRequestDto request) {

        // 유효하지 않은 요청 파라미터 검사 및 예외 처리
        if (request.getSearchType() != null && isInvalidSearchType(request.getSearchType())) {
            throw new ExampleException(ExampleException.Reason.INVALID_REQUEST); // Reason의 메시지를 사용
            // throw new ExampleException(ExampleException.Reason.INVALID_REQUEST, "앞에 붙는",
            // "뒤에 붙는"); // Reason의 앞 뒤에 메시지를 동적으로 생성
            // throw new ExampleException(ExampleException.Reason.INVALID_REQUEST, "예외가
            // 발생하였습니다."); // Reason의 메시지를 사용하지 않는 메시지
        }

        // List<ExampleListResponseDto> resultList =
        // exampleMapper.selectByCriteriaPaging(request);

        PagingResponseDto<ExampleListResponseDto> pagingResult = findData(exampleMapper, "selectByCriteriaPaging", request);

        return pagingResult;
    }

    /**
     * 주어진 검색 조건(request)을 기반으로 데이터를 조회합니다.
     *
     * @param request 검색 조건을 포함하는 요청 객체
     * @return 검색 조건에 부합하는 데이터 목록
     * @throws ExampleException 유효하지 않은 검색 타입인 경우
     */
    public List<ExampleDetailResponseDto> findByCriteria(ExampleListRequestDto request) {

        // 유효하지 않은 요청 파라미터 검사 및 예외 처리
        if (request.getSearchType() != null && isInvalidSearchType(request.getSearchType())) {
            throw new ExampleException(ExampleException.Reason.INVALID_REQUEST);
        }

        return exampleMapper.selectByCriteria(request);
    }

    /**
     * 주어진 사용자 ID(userId)를 기반으로 데이터를 조회합니다.
     *
     * @param userId 조회할 사용자 ID
     * @return 조회된 사용자 정보
     */
    public ExampleDetailResponseDto findById(String userId) {
        return exampleMapper.selectById(userId);
    }

    /**
     * 새로운 데이터를 생성합니다.
     *
     * @param request 생성할 데이터를 포함하는 요청 객체
     * @return 생성된 데이터의 상세 정보
     * @throws ExampleException 유효하지 않은 요청 파라미터 또는 중복된 ID인 경우
     */
    @Transactional
    public ExampleDetailResponseDto create(ExampleRegisterRequestDto request) {

        // 유효하지 않은 요청 파라미터 검사 및 예외 처리
        if (StringUtils.isNullEmpty(request.getUserId()) || StringUtils.isNullEmpty(request.getUserName()) || request.getAge() == null || request.getAge() < 0) {
            throw new ExampleException(ExampleException.Reason.INVALID_REQUEST);
        }

        // 중복된 아이디 존재할 시에 예외 처리
        if (exampleMapper.existsUserId(request.getUserId())) {
            log.error("{} : {}", Message.getMessage("example.duplicate.id"), request.getUserId());
            throw new ExampleException(ExampleException.Reason.DUPLICATE_ID);
        }

        // 데이터를 생성
        exampleMapper.createExample(request);

        // 이력 적재
        ExampleDetailResponseDto createdExample = exampleMapper.selectById(request.getUserId()); // 삽입 후, ID로 재조회하여 최종
                                                                                                 // 상태 반환
        historyAppendService.insertHistoryForTqms("a_test_table_q", HistoryType.INSERT, "[삽입] 예제 삽입", createdExample);

        return createdExample;
    }

    /**
     * 데이터를 수정합니다.
     *
     * @param request 수정할 데이터를 포함하는 요청 객체
     * @return 수정된 데이터의 상세 정보
     * @throws ExampleException 유효하지 않은 요청 파라미터 또는 대상 데이터가 없는 경우
     */
    @Transactional
    public ExampleDetailResponseDto update(ExampleModifyRequestDto request) {

        // 유효하지 않은 요청 파라미터 검사 및 예외 처리
        if (StringUtils.isNullEmpty(request.getUserName()) || request.getUpdateId() == null || request.getAge() == null || request.getAge() < 0) {
            throw new ExampleException(ExampleException.Reason.INVALID_REQUEST);
        }

        // 수정 대상 확인 (존재 여부 검사)
        ExampleDetailResponseDto existingExample = exampleMapper.selectById(request.getUserId());
        if (existingExample == null) {
            throw new ExampleException(ExampleException.Reason.INVALID_ID); // 대상이 없을 때 예외 발생
        }

        // 데이터를 수정
        exampleMapper.modifyExample(request);

        // 이력 적재 - 수정 데이터 적재
        historyAppendService.insertHistoryForTqms("a_test_table_q", HistoryType.UPDATE, "[수정] 예제 수정", existingExample);

        // 업데이트 후 최종 상태 조회 및 반환
        ExampleDetailResponseDto updatedExample = exampleMapper.selectById(request.getUserId());
        return updatedExample;
    }

    /**
     * 주어진 사용자 ID(userId)에 해당하는 데이터를 삭제합니다.
     *
     * @param userId 삭제할 사용자 ID
     * @return 삭제 성공 여부
     * @throws ExampleException 대상 데이터가 없는 경우
     */
    @Transactional
    public boolean delete(String userId) {

        // 삭제 대상 확인 (존재 여부 검사)
        ExampleDetailResponseDto existingExample = exampleMapper.selectById(userId);
        if (existingExample == null) {
            throw new ExampleException(ExampleException.Reason.INVALID_ID); // 대상이 없을 때 예외 발생
        }

        // 데이터를 삭제
        int affectedRows = exampleMapper.removeExample(userId);

        // 이력 적재 - 삭제 전 데이터 적재
        historyAppendService.insertHistoryForTqms("a_test_table_q", HistoryType.DELETE, "[삭제] 예제 삭제", existingExample);

        return affectedRows > 0;
    }

    /**
     * 주어진 검색 타입(searchType)이 유효한지 확인합니다.
     *
     * @param searchType 검색 타입
     * @return 검색 타입이 유효하면 true, 그렇지 않으면 false
     */
    private boolean isInvalidSearchType(String searchType) {
        // 유효한 검색 타입 리스트와 비교하여 확인
        return !Arrays.asList("userId", "userName")
            .contains(searchType);
    }

    /**
     * Interface를 사용하여 주어진 검색 조건(request)을 기반으로 데이터를 조회합니다.
     *
     * @param request 검색 조건을 포함하는 요청 객체
     * @return 검색 조건에 부합하는 데이터 목록
     * @throws ExampleException 유효하지 않은 검색 타입인 경우
     */
    public List<ExampleDetailResponseDto> findByCriteriaForIntf(ExampleListRequestDto request) {

        // 유효하지 않은 요청 파라미터 검사 및 예외 처리
        if (request.getSearchType() != null && isInvalidSearchType(request.getSearchType())) {
            throw new ExampleException(ExampleException.Reason.INVALID_REQUEST);
        }

        return exampleMapper.selectByCriteria(request);
    }

}
