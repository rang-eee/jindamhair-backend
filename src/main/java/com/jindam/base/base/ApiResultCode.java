package com.jindam.base.base;

import com.jindam.app.common.exception.CommonException;
import com.jindam.app.example.exception.ExampleException;
import com.jindam.app.user.exception.UserException;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.function.Supplier;

/**
 * API 결과 코드 관련 클래스
 *
 * 이 클래스는 API 요청의 처리 결과에 대한 코드를 정의합니다. <br/>
 *
 * 코드 범위: <br/> - 음수: 오류 처리 관련 코드 <br/> > 400~-500 : HttpStatus 에러 코드와 매핑(코드 인지 향상을 위해) <br/> > 1000~ : 사용자 정의 에러 코드 <br/>
 *
 * - 3자리(100~)번대: 정상 처리 관련 코드 <br/> - 4자리(1000~)대: 각 업무에서 사용하는 결과 코드 (업무별로 200부터 10단위 순차적으로 사용) <br/> > 업무(2자리) + 예외코드(2자리) <br/> > 1000번대 : 서비스 로직 관련 에러 처리 <br/> > 2000번대 : 업무 공통 관련 에러 처리 <br/>
 */
@AllArgsConstructor
public class ApiResultCode {

    /**
     * API 공통 결과 코드
     *
     * API 요청 성공 및 실패와 같은 공통적인 결과를 나타내는 코드입니다.
     */
    @Getter
    @AllArgsConstructor
    public enum Common {
        SUCCESS(200, null), // 공통 - 정상 처리
        FAIL(-500, () -> CommonException.Reason.FAIL), // 공통 - 서비스 로직 상의 오류
        NOT_VALID(-400, () -> CommonException.Reason.NOT_VALID), // HttpStatus 400 입력 값에 대한 유효성 검증을 통과하지 못한 케이스
        REQUIRED_AUTHENTICATION(-401, () -> CommonException.Reason.REQUIRED_AUTHENTICATION), // HttpStatus 401(인증 필요) 에러 케이스
        FORBIDDEN(-403, () -> CommonException.Reason.FORBIDDEN), // HttpStatus 403(권한 없음) 에러 케이스
        NOT_FOUND(-404, () -> CommonException.Reason.NOT_FOUND), // HttpStatus 404(존재하지 않는 리소스) 에러 케이스
        METHOD_NOT_ALLOWED(-405, () -> CommonException.Reason.METHOD_NOT_ALLOWED), // HttpStatus 405(허용되지 않는 메소드) 에러 케이스
        TOO_LARGE(-413, () -> CommonException.Reason.TOO_LARGE), // HttpStatus 413(요청 데이터 용량 초과) 에러 케이스
        UNSUPPORTED_TYPE(-415, () -> CommonException.Reason.UNSUPPORTED_TYPE), // HttpStatus 415(지원하지 않는 콘텐츠 유형) 에러 케이스
        DUPLICATE(-500, () -> CommonException.Reason.DUPLICATE), // Database Duplicate 에러
        ;

        private final Integer code;
        private final Supplier<BaseReason> reasonSupplier;

        public BaseReason getReason() {
            return reasonSupplier.get();
        }
    }

    /**
     * Example API 결과 코드
     *
     * Example API에서 발생할 수 있는 결과 코드입니다. <br/> 각 코드는 `ExampleException.Reason`과 연결되어 있어, 예외 발생 시 적절한 코드와 메시지를 제공합니다.
     */
    @Getter
    @AllArgsConstructor
    public enum Example {
        INVALID_REQUEST(1101, () -> ExampleException.Reason.INVALID_REQUEST), // 요청 파라미터 이상
        INVALID_ID(1102, () -> ExampleException.Reason.INVALID_ID), // 유효하지 않은 아이디
        NOT_EXIST_NAME(1103, () -> ExampleException.Reason.NOT_EXIST_NAME), // 존재하지 않는 이름
        DUPLICATE_ID(1104, () -> ExampleException.Reason.DUPLICATE_ID), // 중복된 아이디 존재
        ;

        private final Integer code;
        private final Supplier<BaseReason> reasonSupplier;

        public BaseReason getReason() {
            return reasonSupplier.get();
        }
    }

    /**
     * User API 결과 코드
     *
     * User API에서 발생할 수 있는 결과 코드입니다. <br/> 각 코드는 `UserException.Reason`과 연결되어 있어, 예외 발생 시 적절한 코드와 메시지를 제공합니다.
     */
    @Getter
    @AllArgsConstructor
    public enum User {
        INVALID_REQUEST(2001, () -> UserException.Reason.INVALID_REQUEST), // 요청 파라미터 이상
        INVALID_ID(2002, () -> UserException.Reason.INVALID_ID), // 유효하지 않은 아이디
        NOT_EXIST_NAME(2003, () -> UserException.Reason.NOT_EXIST_NAME), // 존재하지 않는 이름
        DUPLICATE_ID(2004, () -> UserException.Reason.DUPLICATE_ID), // 중복된 아이디 존재
        ;

        private final Integer code;
        private final Supplier<BaseReason> reasonSupplier;

        public BaseReason getReason() {
            return reasonSupplier.get();
        }
    }
}
