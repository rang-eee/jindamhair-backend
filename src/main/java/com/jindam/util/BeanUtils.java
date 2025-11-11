package com.jindam.util;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

/**
 * Spring Bean을 가져오기 위한 유틸리티 클래스.
 * <p>
 * Spring의 {@link ApplicationContext}를 활용하여, <br/>
 * 런타임에서 특정 Bean을 조회할 수 있도록 지원하는 역할을 수행한다.
 */
@Component
public class BeanUtils implements ApplicationContextAware {

    // 애플리케이션 컨텍스트를 저장하는 정적 변수
    private static ApplicationContext applicationContext;

    /**
     * Spring이 애플리케이션 컨텍스트(ApplicationContext)를 설정할 때 호출되는 메서드.
     * <p>
     * 이 메서드는 {@link ApplicationContextAware} 인터페이스를 구현하여 <br/>
     * Spring 컨텍스트를 전역적으로 접근할 수 있도록 저장한다.
     *
     * @param applicationContext Spring 애플리케이션 컨텍스트
     * @throws BeansException Spring 컨텍스트 설정 중 발생하는 예외
     */
    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        BeanUtils.applicationContext = applicationContext;
    }

    /**
     * Bean 타입을 기반으로 Spring 컨테이너에서 해당 Bean을 가져오는 메서드.
     *
     * @param <T> 조회할 Bean의 타입
     * @param cls 조회할 Bean의 클래스 타입
     * @return 조회된 Bean 객체
     */
    public static <T> T getBean(Class<T> cls) {
        return applicationContext.getBean(cls);
    }

    /**
     * Bean 이름과 타입을 기반으로 Spring 컨테이너에서 해당 Bean을 가져오는 메서드.
     *
     * @param <T> 조회할 Bean의 타입
     * @param name 조회할 Bean의 이름
     * @param cls 조회할 Bean의 클래스 타입
     * @return 조회된 Bean 객체
     */
    public static <T> T getBean(String name, Class<T> cls) {
        return applicationContext.getBean(name, cls);
    }
}
