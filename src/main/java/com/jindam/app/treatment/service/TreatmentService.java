package com.jindam.app.treatment.service;

import com.jindam.app.treatment.mapper.TreatmentMapper;
import com.jindam.app.treatment.model.*;
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
     * 디자이너 시술 메뉴 수정 (삭제 포함)
     *
     * @param request 수정할 메뉴 정보
     */
    public int updateDesignerTreatment(DesignerTreatmentUpdateRequestDto request) {
        int result = 0;
        String addYn = request.getAddYn();

        if (addYn.equals("Y")) {
            List<DesignerTreatmentAddDetailResponseDto> aList = request.getTreatmentAddList();

            if (aList == null || aList.isEmpty()) {
                for (DesignerTreatmentAddDetailResponseDto b : aList) {
                    DesignerTreatmentAddInsertRequestDto insertDto = DesignerTreatmentAddInsertRequestDto.builder()
                            .designerTreatmentId(b.getDesignerTreatmentId())
                            .hairAddTypeCode(b.getHairAddTypeCode())
                            .addAmount(b.getAddAmount())
                            .build();
                    result = treatmentMapper.insertDesignerTreatmentAddList(insertDto);
                }

            }

            for (DesignerTreatmentAddDetailResponseDto b : aList) {
                DesignerTreatmentAddUpdateRequestDto updateDto = DesignerTreatmentAddUpdateRequestDto.builder()
                        .designerTreatmentAddId(b.getDesignerTreatmentAddId())
                        .designerTreatmentId(b.getDesignerTreatmentId())
                        .hairAddTypeCode(b.getHairAddTypeCode())
                        .addAmount(b.getAddAmount())
                        .build();

                result = treatmentMapper.updateDesignerTreatmentAddList(updateDto);
            }
        } else if (addYn.equals("N")) {// N이면 삭제
            result = treatmentMapper.deleteDesignerTreatmentAddList(request);
        }

        result = treatmentMapper.updateDesignerTreatment(request);
        return result;
    }

    /**
     * 디자이너 시술 메뉴 목록 조회
     *
     * @param request 디자이너 ID
     * @return 메뉴 목록
     */
    public List<DesignerTreatmentDetailResponseDto> selectDesignerTreatmentList(DesignerTreatmentDetailRequestDto request) {
        List<DesignerTreatmentDetailResponseDto> resultList;
        resultList = treatmentMapper.selectDesignerTreatmentList(request);
        return resultList;
    }

    /**
     * 디자이너 시술 메뉴 상세조회
     *
     * @param request
     * @return
     */
    public List<DesignerTreatmentAddDetailResponseDto> selectDesignerTreatmentAddList(DesignerTreatmentDetailRequestDto request) {
        List<DesignerTreatmentAddDetailResponseDto> resultList;
        resultList = treatmentMapper.selectDesignerTreatmentAddList(request);
        return resultList;
    }
}
