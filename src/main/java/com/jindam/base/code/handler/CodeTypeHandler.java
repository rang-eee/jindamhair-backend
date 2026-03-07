package com.jindam.base.code.handler;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

/**
 * MyBatis TypeHandler: DB 문자열 → Java Enum 변환.
 *
 * <h3>변환 우선순위</h3>
 * <ol>
 * <li>{@link Enum#name()} 직접 매칭 (예: {@code "authComplete"})</li>
 * <li>{@link CodeEnum#getFront()} 매칭 (예: {@code "DesignerAuthStatusType.authComplete"})</li>
 * <li>{@link CodeEnum#getText()} 매칭 (예: {@code "승인"})</li>
 * <li>'.' 포함 시 접두어 제거 후 name 매칭 (예: {@code "DesignerAuthStatusType.authComplete"} → {@code "authComplete"})</li>
 * </ol>
 */
public class CodeTypeHandler<E extends Enum<E>> extends BaseTypeHandler<E> {
    private final Class<E> type;

    public CodeTypeHandler(Class<E> type) {
        this.type = type;
    }

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, E parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter.name());
    }

    @Override
    public E getNullableResult(ResultSet rs, String columnName) throws SQLException {
        return from(rs.getString(columnName));
    }

    @Override
    public E getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        return from(rs.getString(columnIndex));
    }

    @Override
    public E getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        return from(cs.getString(columnIndex));
    }

    private E from(String code) {
        if (code == null || code.isBlank()) {
            return null;
        }

        String trimmed = code.trim();

        // 1) enum name 직접 매칭
        try {
            return Enum.valueOf(type, trimmed);
        } catch (IllegalArgumentException ignored) {
            // fallback 진행
        }

        // CodeEnum 구현체인 경우 front / text 매칭
        if (CodeEnum.class.isAssignableFrom(type)) {
            E[] constants = type.getEnumConstants();

            // 2) front 값 매칭 (예: "DesignerAuthStatusType.authComplete")
            for (E constant : constants) {
                CodeEnum ce = (CodeEnum) constant;
                if (trimmed.equals(ce.getFront())) {
                    return constant;
                }
            }

            // 3) text 값 매칭 (예: "승인")
            for (E constant : constants) {
                CodeEnum ce = (CodeEnum) constant;
                if (trimmed.equals(ce.getText())) {
                    return constant;
                }
            }
        }

        // 4) '.' 포함 시 접두어 제거 후 name 매칭 (레거시 Flutter .toString() 형식)
        int lastDot = trimmed.lastIndexOf('.');
        if (lastDot >= 0 && lastDot < trimmed.length() - 1) {
            try {
                return Enum.valueOf(type, trimmed.substring(lastDot + 1));
            } catch (IllegalArgumentException ignored) {
                // fallback 실패
            }
        }

        return null;
    }
}