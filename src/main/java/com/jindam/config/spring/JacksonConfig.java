package com.jindam.config.spring;

import java.util.Set;

import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.type.filter.AssignableTypeFilter;

import com.fasterxml.jackson.databind.Module;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.jindam.base.code.handler.CodeEnum;
import com.jindam.base.code.handler.CodeEnumDeserializer;
import com.jindam.base.code.handler.CodeEnumSerializer;

@Configuration
public class JacksonConfig {

    @SuppressWarnings({ "rawtypes", "unchecked" })
    @Bean
    public Module codeEnumModule() {
        SimpleModule module = new SimpleModule();

        // CodeEnum 인터페이스 기본 등록
        module.addSerializer(CodeEnum.class, new CodeEnumSerializer());
        module.addDeserializer(CodeEnum.class, new CodeEnumDeserializer());

        // 모든 CodeEnum 구현 enum을 개별 등록 — DTO 필드가 구체 타입으로 선언되어도 적용
        ClassPathScanningCandidateComponentProvider scanner = new ClassPathScanningCandidateComponentProvider(false);
        scanner.addIncludeFilter(new AssignableTypeFilter(CodeEnum.class));

        Set<BeanDefinition> candidates = scanner.findCandidateComponents("com.jindam.base.code");
        for (BeanDefinition bd : candidates) {
            try {
                Class<?> clazz = Class.forName(bd.getBeanClassName());
                if (clazz.isEnum() && CodeEnum.class.isAssignableFrom(clazz)) {
                    module.addDeserializer((Class) clazz, new CodeEnumDeserializer((Class) clazz));
                }
            } catch (ClassNotFoundException ignored) {
            }
        }

        return module;
    }
}
