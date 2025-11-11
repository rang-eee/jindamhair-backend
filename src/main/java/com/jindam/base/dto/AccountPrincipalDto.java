package com.jindam.base.dto;

import java.time.LocalDateTime;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.experimental.SuperBuilder;

@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class AccountPrincipalDto {

    private String password; // 비밀번호

    private Integer passwordLockCount; // 비밀번호 잠금 횟수

    private String lockYn; // 잠금 여부

    private String indefiniteUseYn; // 무기한 사용 여부

    private LocalDateTime useStartAt; // 사용 시작 일시

    private LocalDateTime useEndAt; // 사용 종료 일시

    private String apiVendorUseYnTemp; // API 벤더 사용 여부 임시

    private String companyName; // 법인 명

    private List<String> organizationCodes; // 부서 코드 목록

    private List<String> organizationNames; // 부서 명 목록

}
