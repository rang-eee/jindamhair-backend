package com.jindam.app.file.mapper;

import com.jindam.app.file.model.FileDetailResponseDto;

import java.util.List;
import java.util.Map;

public interface FileMapper {

	List<FileDetailResponseDto> selectListFileByFileId(Map<String, Object> param);
}
