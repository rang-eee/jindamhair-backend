package com.jindam.config.spring;

import java.util.Locale;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.context.support.ReloadableResourceBundleMessageSource;
import org.springframework.format.FormatterRegistry;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.AcceptHeaderLocaleResolver;

import com.jindam.base.code.handler.CodeEnumConverterFactory;
import com.jindam.base.message.Message;

/**
 * 다국어 메시지 처리 관련 설정 클래스
 * 
 * 이 클래스는 애플리케이션 내 다국어 메시지 처리를 위해 Spring의 메시지 소스를 설정하고, 요청에 따라 언어를 결정하는 LocaleResolver를 설정합니다.
 */
@Configuration
public class LocaleConfig implements WebMvcConfigurer {

    /**
     * LocaleResolver 빈 설정
     * 
     * AcceptHeaderLocaleResolver를 사용하여, HTTP 요청의 헤더에서 로케일 정보를 읽어와 설정합니다. <br>
     * 기본 로케일은 한국(KOREA)으로 설정되어 있으며, 설정된 로케일은 각 요청에서 메시지 번역에 사용됩니다.
     *
     * @return LocaleResolver 기본 로케일 설정을 포함하는 로케일 리졸버
     */
    @Bean
    LocaleResolver localeResolver() {
        AcceptHeaderLocaleResolver localeResolver = new AcceptHeaderLocaleResolver();
        localeResolver.setDefaultLocale(Locale.KOREA); // 기본 로케일을 한국으로 설정
        return localeResolver;
    }

    /**
     * ReloadableResourceBundleMessageSource 빈 설정
     * 
     * 다국어 메시지 파일의 위치와 인코딩을 설정합니다. <br>
     * i18n/message 파일을 기본으로 참조하며, 파일의 인코딩은 UTF-8로 설정됩니다. <br>
     * 이 설정을 통해 외부 properties 파일에서 다국어 메시지를 관리할 수 있습니다.
     *
     * @return ReloadableResourceBundleMessageSource 메시지 소스 설정을 포함하는 빈
     */
    @Bean(name = "messageSource")
    ReloadableResourceBundleMessageSource messageSource() {
        ReloadableResourceBundleMessageSource source = new ReloadableResourceBundleMessageSource();
        source.setBasenames("classpath:/i18n/message"); // 다국어 메시지 파일 위치 설정
        source.setDefaultEncoding("UTF-8"); // 메시지 파일 인코딩 설정
        return source;
    }

    /**
     * MessageSourceAccessor 빈 설정
     * 
     * ReloadableResourceBundleMessageSource에서 메시지를 쉽게 액세스할 수 있도록 MessageSourceAccessor를 설정합니다.
     *
     * @return MessageSourceAccessor 메시지 소스에 액세스할 수 있는 빈
     */
    @Bean(name = "messageSourceAccessor")
    MessageSourceAccessor getMessageSourceAccessor() {
        return new MessageSourceAccessor(this.messageSource());
    }

    /**
     * Message 빈 설정
     * 
     * Message 클래스를 통해 글로벌 메시지 접근을 가능하게 합니다. <br>
     * MessageSourceAccessor를 Message 클래스에 설정하여 전역적으로 메시지를 관리할 수 있게 합니다.
     *
     * @return Message 다국어 메시지 접근을 위한 빈
     */
    @Bean(name = "messageResolver")
    Message messageResolver() {
        Message.setMessageSourceAccessor(this.getMessageSourceAccessor());
        return new Message();
    }

    /**
     * CodeEnum front 코드 문자열 → Java Enum 자동 변환 등록
     *
     * 프론트엔드가 "BannerType.layer" 같은 front 코드를 쿼리 파라미터로 전송하면,
     * Spring이 자동으로 BannerTypeCode.layer (Java Enum)로 변환합니다.
     */
    @Override
    public void addFormatters(FormatterRegistry registry) {
        registry.addConverterFactory(new CodeEnumConverterFactory());
    }
}
