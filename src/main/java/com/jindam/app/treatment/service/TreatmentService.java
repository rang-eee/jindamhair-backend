package com.jindam.app.treatment.service;

import com.jindam.app.treatment.mapper.TreatmentMapper;
import com.jindam.app.treatment.model.DesignerTreatmentAddInsertRequestDto;
import com.jindam.app.treatment.model.DesignerTreatmentDetailRequestDto;
import com.jindam.app.treatment.model.DesignerTreatmentDetailResponseDto;
import com.jindam.app.treatment.model.DesignerTreatmentUpdateRequestDto;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class TreatmentService extends PagingService {

    private final TreatmentMapper treatmentMapper;

    /**
     * 디자이너 시술 메뉴 추가
     * @param requestList 메뉴 정보 리스트
     */
    public void insertDesignerTreatments(List<DesignerTreatmentAddInsertRequestDto> requestList) {
        requestList.forEach(treatmentMapper::insertDesignerTreatment);
    }

    /**
     * 디자이너 시술 메뉴 수정 (삭제 포함)
     * @param request 수정할 메뉴 정보
     */
    public void updateDesignerTreatment(DesignerTreatmentUpdateRequestDto request) {
        treatmentMapper.updateDesignerTreatment(request);
    }

    /**
     * 디자이너 시술 메뉴 목록 조회
     * @param request 디자이너 ID
     * @return 메뉴 목록
     */
    @Transactional(readOnly = true)
    public List<DesignerTreatmentDetailResponseDto> getDesignerTreatmentList(DesignerTreatmentDetailRequestDto request) {
        return treatmentMapper.selectDesignerTreatmentList(request);
    }
}
