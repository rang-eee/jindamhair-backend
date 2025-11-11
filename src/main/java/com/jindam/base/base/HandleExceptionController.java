package com.jindam.base.base;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.UndeclaredThrowableException;
import java.nio.charset.StandardCharsets;
import java.nio.file.AccessDeniedException;
import java.time.LocalDateTime;
import java.util.Enumeration;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import javax.security.sasl.AuthenticationException;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindException;
import org.springframework.validation.ObjectError;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.web.util.ContentCachingRequestWrapper;

import com.jindam.app.common.exception.CommonException;
import com.jindam.app.common.model.HistoryLogRequestDto;
import com.jindam.app.common.service.HistoryLogService;
import com.jindam.base.dto.ApiResultDto;
import com.jindam.util.StringUtils;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * 예외 발생 시 핸들링을 위한 Controller 클래스
 */
@Slf4j
@RestControllerAdvice
@RequiredArgsConstructor
public class HandleExceptionController {

    private final HistoryLogService historyLogService;

    private final HistoryTransactionManager historyTransactionManager;

    /**
     * 입력 값에 대한 유효성 검증을 통과하지 못한 케이스를 위한 공통 로직
     * 
     * 에러코드 -400
     * 
     * @param exception 예외 객체
     * @return 호출 실패에 대한 응답 데이터
     */
    @ExceptionHandler(value = { MethodArgumentNotValidException.class, ConstraintViolationException.class, MethodArgumentTypeMismatchException.class, BindException.class, MissingServletRequestParameterException.class })
    public ResponseEntity<ApiResultDto<Void>> handleMethodArgumentNotValidException(HttpServletRequest request, Exception exception) {

        CommonException commonException = new CommonException(CommonException.Reason.NOT_VALID);

        ApiResultDto<Void> result = new ApiResultDto<>();
        result.setResultCode(commonException.getReasonCode());
        result.setRawResultMessage(exception.getMessage());

        if (exception instanceof MethodArgumentNotValidException) {
            MethodArgumentNotValidException methodArgumentNotValidException = (MethodArgumentNotValidException) exception;

            List<ObjectError> allErrors = methodArgumentNotValidException.getBindingResult()
                .getAllErrors();

            if (!allErrors.isEmpty()) {

                String msg = allErrors.stream()
                    .map(ObjectError::getDefaultMessage)
                    .collect(Collectors.joining("\n "));

                result.setResultMessage(msg);
            }

            // } else if (exception instanceof ConstraintViolationException constraintViolationException) {
        } else if (exception instanceof ConstraintViolationException) {
            ConstraintViolationException constraintViolationException = (ConstraintViolationException) exception;

            Set<ConstraintViolation<?>> constraintViolations = constraintViolationException.getConstraintViolations();

            if (!constraintViolations.isEmpty()) {

                // @SuppressWarnings("rawtypes")
                // ConstraintViolation constraintViolation = constraintViolations.iterator()
                // .next();

                String msg = constraintViolations.stream()
                    .map(ConstraintViolation::getMessage)
                    .collect(Collectors.joining("\n"));

                // result.setResultMessage(constraintViolation.getMessageTemplate());
                result.setResultMessage(msg);
            }
        } else if (exception instanceof MethodArgumentTypeMismatchException) {
            MethodArgumentTypeMismatchException methodArgumentTypeMismatchException = (MethodArgumentTypeMismatchException) exception;

            result.setResultMessage("MethodArgumentTypeMismatchException: " + methodArgumentTypeMismatchException.getMessage());

        } else if (exception instanceof BindException) {
            BindException bindException = (BindException) exception;

            List<ObjectError> allErrors = bindException.getBindingResult()
                .getAllErrors();
            if (!allErrors.isEmpty()) {
                String msg = allErrors.stream()
                    .map(ObjectError::getDefaultMessage)
                    .collect(Collectors.joining("\n "));
                result.setResultMessage(msg);
            }
        } else if (exception instanceof MissingServletRequestParameterException) {
            MissingServletRequestParameterException missingEx = (MissingServletRequestParameterException) exception;
            result.setResultMessage(missingEx.getParameterType() + " 타입의 " + missingEx.getParameterName() + " 값이 누락되었습니다.");
        }

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
    }

    /**
     * 인증이 필요한 API를 비로그인 상태로 호출했을 경우의 공통 처리 로직.
     *
     * * HTTP 상태 코드: 401 (Unauthorized)
     *
     * @param request 클라이언트의 HTTP 요청 정보.
     * @param response 서버의 HTTP 응답 객체.
     * @param exception 발생한 예외 객체 (AuthenticationException, AccessDeniedException 등).
     * @return 401 상태 코드와 함께 공통 에러 응답(ApiResultDto<Void>) 반환.
     */
    @ExceptionHandler(value = { AuthenticationException.class, AccessDeniedException.class })
    public ResponseEntity<ApiResultDto<Void>> handleAuthorityException(HttpServletRequest request, HttpServletResponse response, Exception exception) {

        // // 로그인 관련 갱신 토큰 쿠키 삭제
        // Cookie jrTokenCookie = new Cookie("jr_token", "");
        // jrTokenCookie.setMaxAge(0);
        // // jrTokenCookie.setDomain(baseDomain);
        // jrTokenCookie.setPath("/");
        // response.addCookie(jrTokenCookie);

        // // 로그인 관련 인증 토큰 쿠키 삭제
        // Cookie jTokenCookie = new Cookie("j_token", "");
        // jTokenCookie.setMaxAge(0);
        // // jTokenCookie.setDomain(baseDomain);
        // jTokenCookie.setPath("/");
        // response.addCookie(jTokenCookie);

        CommonException commonException = new CommonException(CommonException.Reason.REQUIRED_AUTHENTICATION);

        ApiResultDto<Void> result = new ApiResultDto<>();
        result.setResultCode(commonException.getReasonCode());
        result.setResultMessage(commonException.getReasonMessage());

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        return new ResponseEntity<>(result, HttpStatus.UNAUTHORIZED);
    }

    /**
     * 인증이 필요한 API를 인증되지 않은 상태로 호출했을 경우의 공통 처리 로직.
     *
     * * HTTP 상태 코드: 403 (Forbidden)
     *
     * @param request 클라이언트의 HTTP 요청 정보.
     * @param exception 발생한 예외 객체 (AuthenticationException 등).
     * @return 403 상태 코드와 함께 공통 에러 응답(ApiResultDto<Void>) 반환.
     */
    // @ExceptionHandler(value = { Mybatis_AuthCheckException.class })
    // public ResponseEntity<ApiResultDto<Void>> handleAuthenticationCheckException(HttpServletRequest request, MasterException exception) {

    // ApiResultDto<Void> result = new ApiResultDto<>();
    // result.setResultCode(exception.getReasonCode());
    // result.setResultMessage(exception.getReasonMessage());

    // String logContent = getRequestInfo(request, exception);
    // log.error(logContent);

    // return new ResponseEntity<>(result, HttpStatus.FORBIDDEN);
    // }

    /**
     * 404 에러에 대한 공통 로직
     * 
     * 에러코드 -404
     * 
     * @return 404 응답 데이터
     */
    @ExceptionHandler(value = { NoHandlerFoundException.class })
    public ResponseEntity<ApiResultDto<Void>> handleNoHandlerFoundException(HttpServletRequest request, Exception exception) {

        CommonException commonException = new CommonException(CommonException.Reason.NOT_FOUND);

        ApiResultDto<Void> result = new ApiResultDto<>();
        result.setResultCode(commonException.getReasonCode());
        result.setResultMessage(commonException.getReasonMessage());

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        return new ResponseEntity<>(result, HttpStatus.NOT_FOUND);
    }

    /**
     * 405 에러에 대한 공통 로직
     * 
     * 에러코드 -405
     * 
     * @return 405 응답 데이터
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiResultDto<Void>> handleHttpRequestMethodNotSupportedException(HttpServletRequest request, HttpRequestMethodNotSupportedException exception) {

        CommonException commonException = new CommonException(CommonException.Reason.METHOD_NOT_ALLOWED);

        ApiResultDto<Void> result = new ApiResultDto<>();
        result.setResultCode(commonException.getReasonCode());
        result.setResultMessage(commonException.getReasonMessage());

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        return new ResponseEntity<>(result, HttpStatus.METHOD_NOT_ALLOWED);
    }

    /**
     * 파일업로드 용량 초과 오류 handler
     * 
     * 에러코드 -413
     * 
     * @return 413 응답 데이터
     */
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public Object handleSizeLimitExceededException(HttpServletRequest request, MaxUploadSizeExceededException exception) {
        CommonException commonException = new CommonException(CommonException.Reason.TOO_LARGE);

        ApiResultDto<Void> result = new ApiResultDto<>();
        result.setResultCode(commonException.getReasonCode());
        result.setResultMessage(commonException.getReasonMessage());

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        return new ResponseEntity<>(result, HttpStatus.PAYLOAD_TOO_LARGE);
    }

    /**
     * 데이터베이스 중복 handler
     * 
     * 에러코드 -500
     * 
     * @return 500 응답 데이터
     */
    @ExceptionHandler(value = { DuplicateKeyException.class })
    public Object handleDatabaseException(HttpServletRequest request, Exception exception) {
        CommonException commonException = new CommonException(CommonException.Reason.DUPLICATE);

        ApiResultDto<Void> result = new ApiResultDto<>();
        result.setResultCode(commonException.getReasonCode());
        result.setResultMessage(commonException.getReasonMessage());

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        return new ResponseEntity<>(result, HttpStatus.INTERNAL_SERVER_ERROR);
    }

    /**
     * 외부 API 메시지 처리를 위한 예외 익셉션에 대한 핸들러
     *
     * 커스텀 익셉션으로 처리 불가능하므로 BindException 사용함
     *
     * @param exception
     * @return
     */
    @ExceptionHandler(value = { java.net.BindException.class })
    public ResponseEntity<ApiResultDto<Void>> handleBindException(HttpServletRequest request, Exception exception) {

        ApiResultDto<Void> result = new ApiResultDto<>();
        result.setResultCode(ApiResultCode.Common.FAIL.getCode());
        result.setResultMessage(exception.getMessage());

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    /**
     * 커스텀 익셉션에 대한 핸들러
     * 
     * * 각 익셉션 코드
     * 
     * @param exception
     * @return
     */
    @ExceptionHandler(value = { MasterException.class })
    public ResponseEntity<ApiResultDto<Void>> handleCustomException(HttpServletRequest request, MasterException exception) {

        String resultMessage = "";

        String customMessage = exception.getCustomMessage();
        if (StringUtils.isNotNullEmpty(customMessage)) {
            resultMessage = customMessage;
        } else {
            String messagePrefix = exception.getMessagePrefix();
            String messageSuffix = exception.getMessageSuffix();
            resultMessage = (StringUtils.isNotNullEmpty(messagePrefix) ? messagePrefix : "") + exception.getReasonMessage() + (StringUtils.isNotNullEmpty(messageSuffix) ? messageSuffix : "");
        }

        ApiResultDto<Void> result = new ApiResultDto<>();
        result.setResultCode(exception.getReasonCode());
        result.setResultMessage(resultMessage);

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    /**
     * 처리되지 않은 예외 발생 시 대응을 위한 공통 로직
     * 
     * 에러코드 -500
     * 
     * @param request 요청 객체
     * @param exception 예외 객체
     * @return 호출 실패에 따른 응답 데이터
     */
    @ExceptionHandler
    public ResponseEntity<ApiResultDto<Void>> handleException(HttpServletRequest request, Exception exception) {
        CommonException commonException = new CommonException(CommonException.Reason.FAIL);

        String logContent = getRequestInfo(request, exception);
        log.error(logContent);

        // 로그 테이블 데이터 적재
        historyLogService.insertErrorLog(HistoryLogRequestDto.builder()
            .requestInfo(logContent)
            .createId(-1L)
            .createAt(LocalDateTime.now())
            .build());

        return new ResponseEntity<>(new ApiResultDto<>(commonException.getReasonCode(), commonException.getReasonMessage(), null), HttpStatus.INTERNAL_SERVER_ERROR);
    }

    /**
     * 요청 정보를 문자열로 변환하여 반환 (공통 메서드)
     */
    private String getRequestInfo(HttpServletRequest request, Exception exception) {

        // 이력 적재 롤백
        historyTransactionManager.rollback();

        Throwable throwable = exception instanceof UndeclaredThrowableException ? exception.getCause() : exception;

        StringBuilder requestInfo = new StringBuilder();
        requestInfo.append(throwable.getMessage())
            .append("\n");
        requestInfo.append("URL : ")
            .append(request.getRequestURL())
            .append("\n");
        requestInfo.append("Method : ")
            .append(request.getMethod())
            .append("\n");

        requestInfo.append("Request header : \n");
        Enumeration<String> headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String name = headerNames.nextElement();
            String value = request.getHeader(name);
            requestInfo.append("\t")
                .append(name)
                .append("=")
                .append(value)
                .append("\n");
        }

        // 본문 읽기
        String requestBody = getRequestBody(request);
        requestInfo.append("Request Body : \n")
            .append("\t")
            .append(requestBody)
            .append("\n");

        requestInfo.append("Parameter : \n");
        Enumeration<String> parameterNames = request.getParameterNames();
        while (parameterNames.hasMoreElements()) {
            String name = parameterNames.nextElement();
            String value = request.getParameter(name);
            String[] values = request.getParameterValues(name);
            if (values != null && values.length > 0) {
                for (String val : values) {
                    requestInfo.append("\t")
                        .append(name)
                        .append("=")
                        .append(val)
                        .append("\n");
                }
            } else {
                requestInfo.append("\t")
                    .append(name)
                    .append("=")
                    .append(value)
                    .append("\n");
            }
        }

        // 기타 정보 추가
        requestInfo.append("Cookie : \n");
        Cookie[] cookies = request.getCookies();
        for (int i = 0; cookies != null && i < cookies.length; i++) {
            requestInfo.append("\t")
                .append(cookies[i].getName())
                .append("=")
                .append(cookies[i].getValue())
                .append("\n");
        }

        // error stack trace 추가
        requestInfo.append("Stack Trace : \n");
        StringWriter stringWriter = new StringWriter();
        exception.printStackTrace(new PrintWriter(stringWriter));
        String stackTrace = stringWriter.toString();

        requestInfo.append("\t")
            .append(stackTrace);

        return requestInfo.toString();
    }

    private String getRequestBody(HttpServletRequest request) {
        if (!(request instanceof ContentCachingRequestWrapper)) {

            // 요청이 래핑되지 않은 경우 래핑
            request = new ContentCachingRequestWrapper(request);
        }
        ContentCachingRequestWrapper wrapper = (ContentCachingRequestWrapper) request;

        // 본문 캐시 읽기
        String requestBody = new String(wrapper.getContentAsByteArray(), StandardCharsets.UTF_8);
        return requestBody.replace("\"", ""); // 본문에서 따옴표 제거
    }

}