package com.jindam.config.property;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "spring.datasource.major")
public class MajorDatasourceProperties {

    private String driver;
    private String url;
    private String username;
    private String password;
    private Integer minIdle;
    private Integer maxPoolSize;
    private Long maxLifetime;
    private Boolean autoCommit = true;
}
