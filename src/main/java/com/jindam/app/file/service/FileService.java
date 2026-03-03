package com.jindam.app.file.service;

import com.jindam.app.file.mapper.FileMapper;
import com.jindam.app.file.model.FileDetailResponseDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class FileService {

	private final FileMapper fileMapper;

	public List<FileDetailResponseDto> selectListFileByFileId(String fileId) {
		Map<String, Object> param = new HashMap<>();
		param.put("fileId", fileId);
		return fileMapper.selectListFileByFileId(param);
	}
}
