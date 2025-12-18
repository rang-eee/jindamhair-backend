package com.jindam.app.banner.mapper;

import com.jindam.app.banner.model.BannerDetailRequestDto;
import com.jindam.app.banner.model.BannerDetailResponseDto;

/**
 * ExampleMapper 인터페이스
 *
 * <p>
 * 데이터베이스와 상호작용하는 MyBatis Mapper로, Example 관련 CRUD 및 페이징 처리를 위한 메서드를 정의합니다.
 * </p>
 */
public interface BannerMapper {
    BannerDetailResponseDto selectBanner(BannerDetailRequestDto request);
}
