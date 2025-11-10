package com.jindam.base.dto;

import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

/**
 * 파일 리소스와 파일 다운로드 이름을 포함하는 데이터 객체 (DTO)
 * 
 * 이 클래스는 파일 다운로드 또는 미리보기 요청에 필요한 정보를 담는 객체입니다. <br/>
 * 파일 리소스, 파일명, 미디어 유형 등을 포함합니다.
 */
@Getter
@Setter
@Builder
public class ResourceDto {

    /**
     * 실제 파일 리소스를 담는 필드 <br/>
     * Spring의 Resource 객체를 사용하여 파일 데이터를 포함합니다.
     */
    private Resource resource;

    /**
     * 다운로드 시 사용자에게 표시할 파일 이름 <br/>
     * 사용자가 다운로드할 때 볼 파일명을 설정합니다.
     */
    private String downloadFileName;

    /**
     * 파일의 미디어 유형 <br/>
     * 기본값은 `APPLICATION_OCTET_STREAM`으로 설정됩니다.
     */
    @Builder.Default
    private MediaType mediaType = MediaType.APPLICATION_OCTET_STREAM;

    /**
     * 미리보기 여부를 나타내는 필드 <br/>
     * 기본값은 `false`이며, 미리보기가 가능할 경우 `true`로 설정합니다.
     */
    @Builder.Default
    private boolean preview = false;
}
