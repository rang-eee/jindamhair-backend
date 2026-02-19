package com.jindam.app.treatment.controller;

import com.jindam.app.treatment.model.DesignerTreatmentDetailRequestDto;
import com.jindam.app.treatment.model.DesignerTreatmentDetailResponseDto;
import com.jindam.app.treatment.service.TreatmentService;
import com.jindam.base.base.MasterController;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "시술 관련 요청")
@RequiredArgsConstructor
@RestController
@RequestMapping(path = "/treatment")
@Slf4j
public class TreatmentController extends MasterController {

    private final TreatmentService treatmentService;

    @Operation(summary = "시술메뉴 목록 조회", description = "")
    @GetMapping("/")
    public DesignerTreatmentDetailResponseDto selectDesignerTreatment(DesignerTreatmentDetailRequestDto request) {
        DesignerTreatmentDetailResponseDto result = null;
        return result;
    }

    //    @Operation(summary = "시술메뉴 상세 조회", description = "")
    //    @GetMapping("/detail")

}
