package com.jindam.app.banner.service;

import com.jindam.app.banner.mapper.BannerMapper;
import com.jindam.app.banner.model.BannerDetailRequestDto;
import com.jindam.app.banner.model.BannerDetailResponseDto;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class BannerService extends PagingService {
    private final BannerMapper bannerMapper;

    public BannerDetailResponseDto selectBanner(BannerDetailRequestDto request) {
        BannerDetailResponseDto result;
        result = bannerMapper.selectBanner(request);

        return result;
    }

}
