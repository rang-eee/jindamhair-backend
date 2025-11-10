package com.jindam.base.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * HTTP 통신 시 응답 정보를 담기 위한 클래스
 */
@Getter
@Setter
public class HttpCurlResponseDto {
	/**
	 * Response Code (200, 404, 500 등)
	 */
	private int responseCode;

	/**
	 * Response Code에 따른 메시지
	 */
	private String responseMessage;

	/**
	 * Response Body의 내용
	 */
	private String responseBody;
}
