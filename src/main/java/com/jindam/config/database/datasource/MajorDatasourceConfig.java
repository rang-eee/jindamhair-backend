package com.jindam.config.database.datasource;

import javax.sql.DataSource;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import com.jindam.config.property.MajorDatasourceProperties;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * Major 데이터베이스 연결 설정 클래스.
 * 
 * <p>
 * Spring Boot와 HikariCP를 사용하여 Major 데이터베이스 연결 풀(DataSource)을 구성합니다.
 * </p>
 */
@Configuration
public class MajorDatasourceConfig {

    /**
     * Major DB에 연결할 DataSource Bean 생성.
     * 
     * <p>
     * HikariCP 설정을 기반으로 데이터베이스 연결 풀을 구성합니다. 이 DataSource는 기본(@Primary)으로 설정되어 Major DB와의 연결에 사용됩니다.
     * </p>
     *
     * @return HikariDataSource Major DB 전용 DataSource 객체
     * @throws RuntimeException 데이터베이스 연결 풀 생성 중 예외 발생 시
     */
    @Primary
    @Bean(name = "dataSourceForMajorDb")
    DataSource dataSourceForMajorDb(MajorDatasourceProperties p) {
        HikariConfig c = new HikariConfig();
        c.setDriverClassName(p.getDriver());
        c.setJdbcUrl(p.getUrl());
        c.setUsername(p.getUsername());
        c.setPassword(p.getPassword());
        c.setConnectionTestQuery("SELECT 'synology'");
        if (p.getMinIdle() != null)
            c.setMinimumIdle(p.getMinIdle());
        if (p.getMaxPoolSize() != null)
            c.setMaximumPoolSize(p.getMaxPoolSize());
        if (p.getMaxLifetime() != null)
            c.setMaxLifetime(p.getMaxLifetime());
        if (p.getAutoCommit() != null)
            c.setAutoCommit(p.getAutoCommit());
        return new HikariDataSource(c);
    }
}
