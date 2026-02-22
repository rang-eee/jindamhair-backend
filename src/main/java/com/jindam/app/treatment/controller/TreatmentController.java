package com.jindam.app.treatment.controller;

import com.jindam.app.treatment.model.DesignerTreatmentAddDetailResponseDto;
import com.jindam.app.treatment.model.DesignerTreatmentDetailRequestDto;
import com.jindam.app.treatment.model.DesignerTreatmentDetailResponseDto;
import com.jindam.app.treatment.model.DesignerTreatmentUpdateRequestDto;
import com.jindam.app.treatment.service.TreatmentService;
import com.jindam.base.base.MasterController;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "시술 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/treatment")
@Slf4j
public class TreatmentController extends MasterController {

    private final TreatmentService treatmentService;

    @Operation(summary = "디자이너 시술메뉴 목록 조회", description = "디자이너 ID로 조회합니다.")
    @GetMapping("/")
    public List<DesignerTreatmentDetailResponseDto> selectDesignerTreatment(DesignerTreatmentDetailRequestDto request) {
        List<DesignerTreatmentDetailResponseDto> result = treatmentService.selectDesignerTreatmentList(request);
        return result;
    }

    @Operation(summary = "디자이너 시술 상세 조회", description = "시술 추가리스트를 조회합니다.")
    @GetMapping("/detail")
    public List<DesignerTreatmentAddDetailResponseDto> selectDesignerTreatmentAddList(DesignerTreatmentDetailRequestDto request) {
        List<DesignerTreatmentAddDetailResponseDto> result = treatmentService.selectDesignerTreatmentAddList(request);
        return result;
    }

    @Operation(summary = "디자이너 시술 수정 요청", description = "디자이너 아이디로 수정요청 합니다.(삭제 요청 포함)")
    @PatchMapping("/")
    public void updateDesignerTreatment(DesignerTreatmentUpdateRequestDto request) {

    }
}
