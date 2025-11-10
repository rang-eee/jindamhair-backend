package com.jindam.base.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

/**
 * 페이징 처리된 데이터를 Response 하기 위한 Vo 클래스
 */
@Getter
@Setter
@SuperBuilder
@AllArgsConstructor
public class PagingRequestWithoutSortDto extends PagingRequestBaseDto {

}
