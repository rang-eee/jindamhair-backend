package com.jindam.app.example.model;

import io.swagger.v3.oas.annotations.media.Schema;
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
@Schema(description = "ExampleRegisterRequestDto")
public class ExampleRegisterRequestDto {

    @Schema(description = "userId", example = "1")
    private String userId;

    @Schema(description = "userName", example = "홍길동")
    private String userName;

    @Schema(description = "age", example = "25")
    private Integer age;

    @Schema(description = "생성자", example = "1")
    private Long createId;

}
