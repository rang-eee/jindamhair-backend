package com.jindam.app.setting.service;

import com.jindam.app.setting.mapper.SettingMapper;
import com.jindam.app.setting.model.SettingResponseDto;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class SettingService extends PagingService {
    private final SettingMapper settingMapper;

    /**
     * @return 앱 빌드 조회 정보
     */
    public SettingResponseDto selectData() {
        SettingResponseDto result = settingMapper.selectConfiguration();
        return result;
    }

}
