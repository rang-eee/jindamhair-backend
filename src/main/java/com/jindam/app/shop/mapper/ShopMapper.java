package com.jindam.app.shop.mapper;

import com.jindam.app.shop.model.*;

import java.util.List;

/**
 * ExampleMapper 인터페이스
 *
 * <p>
 * 데이터베이스와 상호작용하는 MyBatis Mapper로, Example 관련 CRUD 및 페이징 처리를 위한 메서드를 정의합니다.
 * </p>
 */
public interface ShopMapper {

    /**
     * 특정 조건에 따라 Example 데이터를 조회합니다.
     *
     * @return 조건에 맞는 Example 데이터 목록
     */
    List<ShopDetailResponseDto> selectListShop();

    /**
     * @param request 등록 요청 객체
     * @return 입력된 건수
     */
    int insertListShop(DesignerShopInsertRequestDto request);

    /**
     * @param request 등록 요청 객체
     */
    int updateListShop(DesignerShopUpdateRequestDto request);

    /**
     * @param request
     */
    int deleteListShop(DesingerShopDeleteRequestDto request);

    /**
     * uid로 디자이너 헤어샵 테이블 조회
     *
     * @param request 등록 요청 객체
     * @return 입력된 건수
     */
    List<DesingerShopDetailResponseDto> selectListShopById(DesignerShopInsertRequestDto request);
}
