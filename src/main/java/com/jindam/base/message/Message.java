package com.jindam.base.message;

import java.util.Locale;

import org.springframework.context.support.MessageSourceAccessor;

/**
 * 다국어 지원을 위한 Message 클래스<br>
 * JAVA/JSP 영역 모두 동일한 방식으로 메시지 객체에 접근하기 위해 만든 클래스이다.
 */
public class Message {
	/**
	 * 메시지 properties 파일에 접근하기 위한 MessageSourceAccessor
	 */
	private static MessageSourceAccessor messageSourceAccessor;

	/**
	 * MessageSourceAccessor 객체를 Message 클래스에 주입하기 위한 메소드
	 * 
	 * @param messageSourceAccessor 메시지 properties 파일에 접근하기 위한 MessageSourceAccessor
	 */
	public static void setMessageSourceAccessor(MessageSourceAccessor messageSourceAccessor) {
		Message.messageSourceAccessor = messageSourceAccessor;
	}

	/**
	 * messageCode에 해당하는 메시지를 반환<br>
	 * messageCode가 존재하지 않을 경우 메시지 내용 대신 messageCode를 반환
	 * 
	 * @param messageCode 매시지 properties에 정의된 메시지 코드
	 * @return 메시지 내용을 반환
	 */
	public static String getMessage(String messageCode) {
		return Message.messageSourceAccessor.getMessage(messageCode, messageCode);
	}

	/**
	 * messageCode에 해당하는 메시지를 반환<br>
	 * messageCode가 존재하지 않을 경우 메시지 내용 대신 messageCode를 반환
	 * 
	 * @param messageCode 매시지 properties에 정의된 메시지 코드
	 * @param locale 지역 정보 (로케일 정보)
	 * @return 메시지 내용을 반환
	 */
	public static String getMessage(String messageCode, Locale locale) {
		return Message.messageSourceAccessor.getMessage(messageCode, messageCode, locale);
	}

	/**
	 * messageCode에 해당하는 메시지를 반환<br>
	 * 메시지에 정의된 바인딩 변수는 args 파라미터로 치환된다.<br>
	 * messageCode가 존재하지 않을 경우 메시지 내용 대신 messageCode를 반환<br>
	 * 바인딩 변수 정의 예제 : 취소 가능 상태가 아닙니다. (진행중인 {0} 주문이 존재합니다. 현재 주문 상태는 {1} 입니다.)
	 * 
	 * @param messageCode 매시지 properties에 정의된 메시지 코드
	 * @param args 메시지의 바인딩 변수에 치환될 값
	 * @return 메시지 내용을 반환
	 */
	public static String getMessage(String messageCode, Object... args) {
		return Message.messageSourceAccessor.getMessage(messageCode, args, messageCode);
	}

	/**
	 * messageCode에 해당하는 메시지를 반환<br>
	 * 메시지에 정의된 바인딩 변수는 args 파라미터로 치환된다.<br>
	 * messageCode가 존재하지 않을 경우 메시지 내용 대신 messageCode를 반환<br>
	 * 바인딩 변수 정의 예제 : 취소 가능 상태가 아닙니다. (진행중인 {0} 주문이 존재합니다. 현재 주문 상태는 {1} 입니다.)
	 * 
	 * @param messageCode 매시지 properties에 정의된 메시지 코드
	 * @param args 메시지의 바인딩 변수에 치환될 값
	 * @param locale 지역 정보 (로케일 정보)
	 * @return 메시지 내용을 반환
	 */
	public static String getMessage(String messageCode, Locale locale, Object... args) {
		return Message.messageSourceAccessor.getMessage(messageCode, args, messageCode, locale);
	}
}