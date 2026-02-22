package com.jindam.app.treatment.mapper;

import com.jindam.app.treatment.model.*;

import java.util.List;

public interface TreatmentMapper {

    /**
     * 디자이너 시술 메뉴를 추가합니다.
     *
     * @param request 추가할 시술 메뉴 정보
     * @return 영향을 받은 행의 수
     */
    int insertDesignerTreatment(DesignerTreatmentAddInsertRequestDto request);

    /**
     * 디자이너 시술 메뉴를 수정합니다. (삭제 포함)
     *
     * @param request 수정할 시술 메뉴 정보
     * @return 영향을 받은 행의 수
     */
    int updateDesignerTreatment(DesignerTreatmentUpdateRequestDto request);

    /**
     * 특정 디자이너의 시술 메뉴 목록을 조회합니다.
     *
     * @param request 디자이너 ID
     * @return 시술 메뉴 목록
     */
    List<DesignerTreatmentDetailResponseDto> selectDesignerTreatmentList(DesignerTreatmentDetailRequestDto request);

    /**
     * 디자이너 시술 추가 조회
     *
     * @param request
     * @return
     */
    List<DesignerTreatmentAddDetailResponseDto> selectDesignerTreatmentAddList(DesignerTreatmentDetailRequestDto request);
}
