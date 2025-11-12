package com.jindam.config.swagger;

import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import lombok.RequiredArgsConstructor;

// @Profile({ "local", "dev" })
@Configuration
@RequiredArgsConstructor
public class SwaggerConfig {

    /** 그룹 #1: /api/** */
    @Bean
    public GroupedOpenApi api() {
        return GroupedOpenApi.builder()
            .group("v1")
            .addOpenApiCustomizer(openApi -> openApi.getInfo()
                .title("Jindam API v1")
                .version("1.0.0"))
            .build();
    }

}
