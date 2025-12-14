package com.jindam.app.shop.service;

import com.jindam.app.shop.mapper.ShopMapper;
import com.jindam.app.shop.model.*;
import com.jindam.base.base.PagingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = false)
@Slf4j
public class ShopService extends PagingService {
    private final ShopMapper shopMapper;

    /**
     * 주어진 검색 조건(request)을 기반으로 데이터를 조회합니다.
     *
     * @return 검색 조건에 부합하는 데이터 목록
     * @throws
     */
    public List<ShopDetailResponseDto> selectListShop() {

        List<ShopDetailResponseDto> result = shopMapper.selectListShop();

        return result;
    }

    /**
     * 새로운 데이터를 생성합니다.
     *
     * @param List<DesignerShopInsertRequestDto> request 생성할 데이터를 포함하는 요청 객체
     * @return List<DesingerShopDetailResponseDto>
     */
    public List<DesingerShopDetailResponseDto> insertListShop(List<DesignerShopInsertRequestDto> request) {
        for (DesignerShopInsertRequestDto input : request) {
            try {
                //단건 인서트
                shopMapper.insertListShop(input);
            } catch (Exception e) {
                //exception 추가
                throw e;
            }
        }
        DesingerShopDetailResponseDto uid;
        List<DesingerShopDetailResponseDto> rtn;

        uid = DesingerShopDetailResponseDto.from(request.get(0));
        rtn = shopMapper.selectListShopById(uid);

        return rtn;
    }

    /**
     * @param List<DesignerShopUpdateRequestDto> request
     * @return List<DesingerShopDetailResponseDto>
     */
    public List<DesingerShopDetailResponseDto> updateListShop(List<DesignerShopUpdateRequestDto> request) {

        for (DesignerShopUpdateRequestDto input : request) {
            try {
                //업데이트
                shopMapper.updateListShop(input);
            } catch (Exception e) {
                throw e;
            }
        }
        DesingerShopDetailResponseDto uid;
        List<DesingerShopDetailResponseDto> rtn;

        uid = DesingerShopDetailResponseDto.from(request.get(0));
        rtn = shopMapper.selectListShopById(uid);

        return rtn;
    }

    /**
     * @param List<DesingerShopDeleteRequestDto> request
     * @return List<DesingerShopDetailResponseDto>
     */
    public List<DesingerShopDetailResponseDto> deleteListShop(List<DesingerShopDeleteRequestDto> request) {

        for (DesingerShopDeleteRequestDto input : request) {
            try {
                //딜리트
                shopMapper.deleteListShop(input);
            } catch (Exception e) {
                throw e;
            }
        }
        DesingerShopDetailResponseDto uid;
        List<DesingerShopDetailResponseDto> rtn;

        uid = DesingerShopDetailResponseDto.from(request.get(0));
        rtn = shopMapper.selectListShopById(uid);

        return rtn;
    }
}
