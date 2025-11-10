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
@Schema(description = "ExampleModifyRequestDto")
public class ExampleModifyRequestDto {

    @Schema(hidden = true)
    private String userId;

    @Schema(description = "userName", example = "홍길동")
    private String userName;

    @Schema(description = "age", example = "25")
    private Integer age;

    @Schema(description = "업데이트 사용자", example = "1")
    private Long updateId;

}
