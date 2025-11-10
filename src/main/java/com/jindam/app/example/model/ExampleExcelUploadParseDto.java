package com.jindam.app.example.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.jindam.base.annotation.XlsxReadMappingField;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class ExampleExcelUploadParseDto {

    @XlsxReadMappingField(column = "사용자 ID")
    private String userId;

    @XlsxReadMappingField(column = "사용자 이메일")
    private String accountEmail;

    @XlsxReadMappingField(column = "사용자 명")
    private String accountName;

    @XlsxReadMappingField(column = "나이")
    private Integer age;

    @XlsxReadMappingField(column = "신장")
    private Double height;

    @XlsxReadMappingField(column = "등록일")
    private LocalDate registDate;

    @XlsxReadMappingField(column = "등록일시")
    private LocalDateTime registDatetime;
}
