package com.jindam.config.spring;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.fasterxml.jackson.databind.Module;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.jindam.base.code.handler.CodeEnum;
import com.jindam.base.code.handler.CodeEnumSerializer;

@Configuration
public class JacksonConfig {

    @Bean
    public Module codeEnumModule() {
        SimpleModule module = new SimpleModule();
        module.addSerializer(CodeEnum.class, new CodeEnumSerializer());
        return module;
    }
}
