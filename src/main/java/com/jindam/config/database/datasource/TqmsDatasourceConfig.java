package com.jindam.config.database.datasource;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * TQMS 데이터베이스 연결 설정 클래스.
 * 
 * <p>
 * Spring Boot와 HikariCP를 사용하여 TQMS 데이터베이스 연결 풀(DataSource)을 구성합니다.
 * </p>
 */
@Configuration
public class TqmsDatasourceConfig {

    // TQMS 데이터베이스 드라이버 클래스
    @Value("${spring.datasource.tqms.driver}")
    private String driver;

    // TQMS 데이터베이스 URL
    @Value("${spring.datasource.tqms.url}")
    private String url;

    // TQMS 데이터베이스 사용자 이름
    @Value("${spring.datasource.tqms.username}")
    private String username;

    // TQMS 데이터베이스 비밀번호
    @Value("${spring.datasource.tqms.password}")
    private String password;

    // HikariCP 설정: 최소 유휴 커넥션 개수
    @Value("${spring.datasource.tqms.minIdle}")
    private int minIdle;

    // HikariCP 설정: 최대 커넥션 풀 크기
    @Value("${spring.datasource.tqms.maxPoolSize}")
    private int maxPoolSize;

    // HikariCP 설정: 커넥션 최대 생명주기 (밀리초)
    @Value("${spring.datasource.tqms.maxLifetime}")
    private long maxLifetime;

    // HikariCP 설정: AutoCommit 여부
    @Value("${spring.datasource.tqms.autoCommit}")
    private boolean autoCommit;

    /**
     * TQMS DB에 연결할 DataSource Bean 생성.
     * 
     * <p>
     * HikariCP 설정을 기반으로 데이터베이스 연결 풀을 구성합니다. 이 DataSource는 기본(@Primary)으로 설정되어 TQMS DB와의 연결에 사용됩니다.
     * </p>
     *
     * @return HikariDataSource TQMS DB 전용 DataSource 객체
     * @throws RuntimeException 데이터베이스 연결 풀 생성 중 예외 발생 시
     */
    @Primary
    @Bean(name = "dataSourceForTqmsDb")
    DataSource dataSourceForTqmsDb() {
        try {
            // HikariCP 설정 객체 생성
            HikariConfig hikariConfig = new HikariConfig();
            hikariConfig.setDriverClassName(this.driver); // 데이터베이스 드라이버 설정
            hikariConfig.setJdbcUrl(this.url); // 데이터베이스 URL 설정
            hikariConfig.setUsername(this.username); // 사용자 이름 설정
            hikariConfig.setPassword(this.password); // 비밀번호 설정

            // 커넥션 풀 테스트 쿼리 설정
            hikariConfig.setConnectionTestQuery("SELECT 'tqms'");

            // HikariCP 커넥션 풀 크기 및 성능 관련 설정
            hikariConfig.setMinimumIdle(this.minIdle); // 최소 유휴 커넥션 개수
            hikariConfig.setMaximumPoolSize(this.maxPoolSize); // 최대 커넥션 풀 크기
            hikariConfig.setMaxLifetime(this.maxLifetime); // 커넥션 최대 생명주기
            // hikariConfig.setAutoCommit(this.autoCommit); // AutoCommit 설정. read-only를 위한 데이터 소스가 존재하지 않아 필요없음

            // HikariDataSource 객체 생성 및 반환
            DataSource dataSource = new HikariDataSource(hikariConfig);
            return dataSource;
        } catch (Exception e) {
            e.printStackTrace();
            throw e; // 예외 발생 시 재전달
        }
    }
}
