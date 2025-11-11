package com.jindam.config.database.mybatis;

import java.sql.Array;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

public class ListStringArrayTypeHandler extends BaseTypeHandler<List<String>> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, List<String> parameter, JdbcType jdbcType) throws SQLException {
        // List를 PostgreSQL 배열로 변환
        String[] array = parameter.toArray(new String[0]);
        ps.setArray(i, ps.getConnection()
            .createArrayOf("text", array));
    }

    @Override
    public List<String> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        Array array = rs.getArray(columnName);
        if (array == null || array.getArray() == null) {
            return List.of(); // 빈 리스트 반환
        }
        return Arrays.stream((Object[]) array.getArray())
            .map(Object::toString)
            .collect(Collectors.toList());
    }

    @Override
    public List<String> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        Array array = rs.getArray(columnIndex);
        if (array == null) {
            return null;
        }
        return Arrays.stream((Object[]) array.getArray())
            .map(Object::toString)
            .collect(Collectors.toList());
    }

    @Override
    public List<String> getNullableResult(java.sql.CallableStatement cs, int columnIndex) throws SQLException {
        Array array = cs.getArray(columnIndex);
        if (array == null) {
            return null;
        }
        return Arrays.stream((Object[]) array.getArray())
            .map(Object::toString)
            .collect(Collectors.toList());
    }
}
