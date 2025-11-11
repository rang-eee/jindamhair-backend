package com.jindam.base.dto;

import java.util.List;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.CollectionType;
import com.fasterxml.jackson.databind.type.TypeFactory;
import com.jindam.base.message.Message;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

/**
 * Rest API 호출 결과에 따른 응답 처리를 위한 Vo 클래스
 * 
 * @param <T> 응답 데이터의 타입
 */
@Getter
@Setter
@Builder
public class ApiResultDto<T> {

    @Schema(description = "API 호출 결과 코드", example = "200", required = true)
    private Integer resultCode; // API 결과 코드 (예: 성공 또는 오류 코드)

    @Schema(description = "API 호출 결과 메시지", example = "성공적으로 처리하였습니다.", required = true)
    private String resultMessage; // API 결과 메시지

    @Schema(description = "API 호출 결과 데이터(T)", example = "String, Json, Array 등등")
    private T data; // API 응답 데이터

    private static ObjectMapper objectMapper; // JSON 데이터 변환을 위한 ObjectMapper 인스턴스

    // 정적 초기화 블록: ObjectMapper 설정
    // static {
    // if (objectMapper == null) {
    // objectMapper = new ObjectMapper();
    // objectMapper.registerModule(new JavaTimeModule());

    // // Hibernate와의 통합 설정
    // Hibernate5JakartaModule hibernate5Module = new Hibernate5JakartaModule();
    // hibernate5Module.configure(Hibernate5JakartaModule.Feature.FORCE_LAZY_LOADING, false);
    // objectMapper.registerModule(hibernate5Module);
    // }
    // }

    /**
     * 기본 생성자. 기본 결과 코드를 200으로 설정합니다.
     */
    public ApiResultDto() {
        this.resultCode = 200; // 기본 성공 코드 설정
        this.resultMessage = Message.getMessage("common.proc.success"); // 기본 성공 메시지
    }

    /**
     * 생성자: 결과 코드, 메시지 키, 데이터를 받아 ApiResultVo 객체를 생성
     * 
     * @param resultCode 결과 코드
     * @param key 메시지 키
     * @param data 응답 데이터
     */
    public ApiResultDto(Integer resultCode, String key, T data) {
        this.resultCode = resultCode;
        this.resultMessage = Message.getMessage(key);
        this.data = data;
    }

    /**
     * 결과 코드와 메시지 키, 데이터를 포함하여 ApiResultVo 객체를 생성
     *
     * @param resultCode 결과 코드
     * @param key 메시지 키
     * @param data 응답 데이터
     * @param <T> 응답 데이터의 타입
     * @return ApiResultVo 객체
     */
    public static <T> ApiResultDto<T> response(Integer resultCode, String key, T data) {
        return new ApiResultDto<>(resultCode, key, data);
    }

    /**
     * 결과 코드와 메시지 키를 포함하여 ApiResultVo 객체를 생성
     *
     * @param resultCode 결과 코드
     * @param key 메시지 키
     * @param <T> 응답 데이터의 타입
     * @return ApiResultVo 객체
     */
    public static <T> ApiResultDto<T> response(Integer resultCode, String key) {
        return new ApiResultDto<>(resultCode, key);
    }

    /**
     * data가 없는 생성자: 결과 코드와 메시지 키만을 받아 ApiResultVo 객체를 생성
     * 
     * @param resultCode 결과 코드
     * @param key 메시지 키
     */
    public ApiResultDto(Integer resultCode, String key) {
        this.resultCode = resultCode;
        this.resultMessage = Message.getMessage(key);
    }

    /**
     * data가 없는 생성자: 결과 코드와 메시지 키만을 받아 ApiResultVo 객체를 생성
     * 
     * @param resultCode 결과 코드
     * @param key 메시지 키
     */
    public ApiResultDto(String key) {
        this.resultCode = 200;
        this.resultMessage = Message.getMessage(key);
    }

    /**
     * 결과 메시지를 설정하는 메소드.
     * 
     * 다국어 지원을 위해 메시지 키를 사용합니다.
     *
     * @param key 메시지 키
     */
    public void setResultMessage(String key) {
        this.resultMessage = Message.getMessage(key);
    }

    /**
     * 결과 메시지를 설정하는 메소드.
     * 
     * 다국어 지원을 위해 메시지 키와 메시지에 정의된 바인딩 변수를 사용합니다.
     *
     * @param key 메시지 키
     * @param args 바인딩 변수에 치환될 값
     */
    public void setResultMessage(String key, Object... args) {
        this.resultMessage = Message.getMessage(key, args);
    }

    /**
     * 결과 메시지를 원시 형태의 문자열로 설정하는 메소드
     * 
     * @param rawMessage 직접 설정할 메시지 문자열
     */
    public void setRawResultMessage(String rawMessage) {
        this.resultMessage = rawMessage;
    }

    /**
     * 데이터 타입에 따라 data 필드를 설정하는 메소드
     * 
     * @param data 설정할 데이터
     * @param type 변환할 대상 타입
     */
    public void setData(T data) {
        if (data instanceof List) {
            List<?> listData = (List<?>) data;
            if (listData.isEmpty()) {
                this.data = null;
                this.setResultMessage("common.proc.failed.search.empty");
                return;
            }

        } else {
            if (data == null) {
                this.data = null;
                this.setResultMessage("common.proc.failed.search.empty");
                return;
            }

        }

        this.data = data;
    }

    /**
     * 데이터 타입에 따라 data 필드를 설정하는 메소드
     * 
     * @param data 설정할 데이터
     * @param type 변환할 대상 타입
     */
    @SuppressWarnings({ "rawtypes", "unchecked" })
    public void setData(Object data, Class type) {
        if (data instanceof List) {
            List<?> listData = (List<?>) data;
            if (listData.isEmpty()) {
                // List가 비어있는 경우: data는 null로 설정하고, 실패 메시지 설정
                this.data = null;
                this.setResultMessage("common.proc.failed.search.empty");
            } else {
                // List에 데이터가 있는 경우
                CollectionType collectionType = TypeFactory.defaultInstance()
                    .constructCollectionType(List.class, type);
                this.data = ApiResultDto.objectMapper.convertValue(listData, collectionType);
            }
        } else {
            if (data == null) {
                this.data = null;
                this.setResultMessage("common.proc.failed.search.empty");
                return;
            }

            // 그 외의 일반 데이터일 경우
            this.data = (T) ApiResultDto.objectMapper.convertValue(data, type);
        }
    }

}
