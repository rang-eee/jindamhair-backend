package com.jindam.base.code.handler;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

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
        if (code == null || code.isBlank())
            return null;
        return Enum.valueOf(type, code);
    }
}