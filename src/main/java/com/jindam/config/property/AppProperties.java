package com.jindam.config.property;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.apache.commons.lang3.StringUtils;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties("app")
public class AppProperties {

    private String name;

    private String host;

    private String swagger;

    private String url;

    private String version = "0.0.1";

    private Oauth oauth = new Oauth();

    public String getSwaggerHost() {
        if (StringUtils.isNotEmpty(swagger))
            return swagger;
        return host;
    }

    @Getter
    @Setter
    @ToString
    public static class Oauth {

        private boolean enabled;
        private String clientId;
        private String clientSecret;
        private String tokenSigningKey;
        private int tokenValiditySeconds = 1 * 24 * 60 * 60;
        private int refreshTokenValiditySeconds = 10 * 24 * 60 * 60;
    }

}
