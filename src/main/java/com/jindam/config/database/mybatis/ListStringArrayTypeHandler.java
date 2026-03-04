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
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;

@MappedTypes(List.class)
@MappedJdbcTypes(JdbcType.ARRAY)
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
        try {
            Array array = rs.getArray(columnName);
            if (array == null || array.getArray() == null) {
                return List.of();
            }
            return Arrays.stream((Object[]) array.getArray())
                .map(Object::toString)
                .collect(Collectors.toList());
        } catch (SQLException e) {
            // PostgreSQL JDBC 배열 읽기 실패 시 문자열 파싱 fallback
            String val = rs.getString(columnName);
            if (val == null || val.isEmpty()) {
                return List.of();
            }
            // PostgreSQL 배열 리터럴: {a,b,c}
            val = val.replaceAll("^\\{|\\}$", "");
            if (val.isEmpty()) {
                return List.of();
            }
            return Arrays.stream(val.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
        }
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
