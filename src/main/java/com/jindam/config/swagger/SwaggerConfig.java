package com.jindam.config.swagger;

import java.util.List;

import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import com.jindam.config.property.AppProperties;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import lombok.RequiredArgsConstructor;

@Profile({ "local", "dev" })
@Configuration
@RequiredArgsConstructor
public class SwaggerConfig {

    private final AppProperties appProperties;

    /** 공통 OpenAPI 스펙 (Info / Servers) — 보안 섹션 제거 */
    @Bean
    public OpenAPI openAPI() {
        String host = appProperties.getSwaggerHost(); // 예: api.example.com
        String serverUrl = (host != null && !host.isBlank()) ? "https://" + host : "/";

        return new OpenAPI().info(new Info().title(appProperties.getName())
            .description("아워홈 Qsis api 정보")
            .version("2.0.0")
            .contact(new Contact().name("아워홈")
                .url("https://www.ourhome.co.kr")
                .email("example@gmail.com")))
            .servers(List.of(new Server().url(serverUrl)));
    }

    /** 그룹 #1: /api/** */
    @Bean
    public GroupedOpenApi api() {
        return GroupedOpenApi.builder()
            .group("default")
            .pathsToMatch("/api/**")
            .build();
    }

    /** 그룹 #2: /v1/api/** */
    @Bean
    public GroupedOpenApi v1Api() {
        return GroupedOpenApi.builder()
            .group("default_new")
            .pathsToMatch("/v1/api/**")
            .build();
    }
}
