package com.jindam.config.database.mybatis;

import java.util.List;

import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.type.JdbcType;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.mybatis.spring.boot.autoconfigure.ConfigurationCustomizer;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import com.jindam.config.spring.BeanNameGenerator;

/**
 * MyBatis 설정 클래스 (Major DB 전용)
 * 
 * <p>
 * Major 관련 MyBatis 매퍼와 데이터베이스 연결 설정을 정의합니다.
 * </p>
 */
@Configuration
@MapperScan( //
        basePackages = { "com.jindam.app.**.mapper" }, // Major 관련 매퍼 패키지 스캔
        sqlSessionFactoryRef = "majorSqlSessionFactory", // Major DB 전용 SqlSessionFactory 설정
        nameGenerator = BeanNameGenerator.class // Custom Bean Name Generator 사용
)
public class MajorMybatisConfig {

    /**
     * Major DB 전용 SqlSessionFactory 빈 생성
     * 
     * <p>
     * DataSource를 기반으로 MyBatis의 SqlSessionFactory를 생성합니다. 이 설정은 Major DB와 연동되는 매퍼와 MyBatis XML 파일을 처리합니다.
     * </p>
     *
     * <p>
     * Primary로 지정되어 기본 SqlSessionFactory로 설정됩니다.
     * </p>
     *
     * @param dataSourceForMajorDb Major DB에 연결할 DataSource
     * @return Major 전용 SqlSessionFactory 객체
     * @throws Exception SqlSessionFactory 생성 중 오류가 발생할 경우 예외
     */
    @Primary
    @Bean(name = "majorSqlSessionFactory")
    public SqlSessionFactory majorSqlSessionFactory(@Qualifier("dataSourceForMajorDb") DataSource dataSourceForMajorDb) throws Exception {
        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSourceForMajorDb); // Major DB 전용 DataSource 설정

        // MyBatis XML 매퍼 파일 경로 설정
        PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
        sessionFactory.setMapperLocations(resolver.getResources("classpath:mybatis/mapper/**/*.xml"));

        // MyBatis 타입 별칭 패키지 설정
        sessionFactory.setTypeAliasesPackage("com.jindam.app.**.model");

        // MyBatis 전역 설정 파일 위치 지정
        Resource myBatisConfig = resolver.getResource("classpath:mybatis/mybatis-config.xml");
        sessionFactory.setConfigLocation(myBatisConfig);

        return sessionFactory.getObject();
    }

    @Bean
    public ConfigurationCustomizer configurationCustomizer() {
        return configuration -> {
            configuration.getTypeHandlerRegistry()
                .register(List.class, // Java 타입
                        JdbcType.ARRAY, // JDBC 타입
                        new ListStringArrayTypeHandler() // Custom TypeHandler 객체
            );
        };
    }
}
