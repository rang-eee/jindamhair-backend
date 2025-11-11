package com.jindam.util.validators;

import java.lang.reflect.Field;
import java.nio.CharBuffer;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import org.springframework.util.ObjectUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 공용 유틸리티 클래스
 */
public class CommonUtils {

    /**
     * 검색어를 개행을 기준으로 분리
     *
     * @param searchKeywords 검색어
     * @return 개행을 기준으로 분리된 문자열 배열을 반환
     */
    public String[] setArrSearchKeywords(String searchKeywords) {

        if (searchKeywords == null || searchKeywords.isEmpty()) {
            return null;
        }

        String arrString[] = searchKeywords.split("\\r?\\n");
        List<String> result = new ArrayList<>();

        for (int i = 0; arrString != null && i < arrString.length; i++) {
            String item = arrString[i];
            item = item.trim();
            item = item.replaceAll("&nbsp;", "");

            if (!item.isEmpty()) {
                result.add(item);
            }
        }

        return result.toArray(new String[0]);
    }

    /**
     * 정수형태로 이루어진 문자열인지 검사하는 메소드
     *
     * @param str 정수 형태인지 여부를 검사할 문자열
     * @return false : 정수 형태의 문자열, true : 정수 형태가 아닌 문자열
     */
    public boolean isNaN(String str) {
        boolean result = false;

        try {
            Integer.parseInt(str);
        } catch (NumberFormatException e) {
            result = true;
        }

        return result;
    }

    /**
     * 01012341234 형태의 핸드폰 번호를 {"010", "1234", "1234"} 형태의 문자배열로 나누는 메소드
     *
     * @param cellNo 핸드폰 번호
     * @return 분할된 핸드폰번호 문자열 배열을 반환, 인자로 받은 cellNo가 null이거나 10자리 미만인 경우 null을 반환
     */
    public String[] divCellNo(String cellNo) {

        String[] result = null;

        if (cellNo != null && !cellNo.isEmpty() && cellNo.length() >= 9) {

            result = new String[3];

            if (cellNo.length() == 10) {
                result[0] = cellNo.substring(0, 3);
                result[1] = cellNo.substring(3, 6);
                result[2] = cellNo.substring(6, 10);
            } else if (cellNo.length() == 9) {
                result[0] = cellNo.substring(0, 2);
                result[1] = cellNo.substring(2, 5);
                result[2] = cellNo.substring(5, 9);
            } else {
                result[0] = cellNo.substring(0, 3);
                result[1] = cellNo.substring(3, 7);
                result[2] = cellNo.substring(7, 11);
            }
        }

        return result;
    }

    /**
     * 01012341234 형태의 핸드폰 번호를 010-1234-1234 형태로 변경하는 메소드<br/>
     * 만약 seperator 인자값을 null이나 빈 문자열이 아닌 값으로 전달하면 핸드폰 번호 사이의 구분기호를 해당 문자열로 대체 가능
     *
     * @param cellNo 01012341234 형태의 핸드폰 번호 문자열
     * @param seperator 핸드폰 번호 사이에 들어갈 구분기호, null이거나 빈 문자열이면 '-'로 처리됨.
     * @return 형태가 변환된 핸드폰 번호 문자열을 반환, 인자로 받은 cellNo가 null이거나 10자리 미만인 경우 null을 반환
     */
    public String formatCellNo(String cellNo, String seperator) {

        String tSeperator = seperator;

        String[] tempDivCellNo = this.divCellNo(cellNo);
        String result = null;

        if (tSeperator == null || tSeperator.isEmpty()) {
            tSeperator = "-";
        }

        if (tempDivCellNo != null && tempDivCellNo.length == 3) {
            result = tempDivCellNo[0];
            result += tSeperator + tempDivCellNo[1];
            result += tSeperator + tempDivCellNo[2];
        }

        return result;
    }

    /**
     * 이메일 주소에서 아이디와 도메인을 나누는 메소드
     *
     * @param email id@radcns.com 형식의 이메일 주소 문자열
     * @return 아이디와 도메인 부분이 분리된 문자열 배열 반환, email이 null이거나 빈 문자열, @ 기호가 없는 경우 null을 반환
     */
    public String[] divEmail(String email) {

        String[] result = null;

        if (email != null && !email.isEmpty() && email.indexOf("@") != -1) {
            result = new String[2];
            result[0] = email.substring(0, email.indexOf("@"));
            result[1] = email.substring(email.indexOf("@") + 1, email.length());
        }

        return result;
    }

    /**
     * 사용자 IP 가져오기
     *
     * @return 현재 요청(HttpServletRequest)에 대한 사용자의 IP를 반환
     */
    public String getUserIP() {

        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();

        // Enumeration<String> requestHeader = request.getHeaderNames();
        // while (requestHeader.hasMoreElements()) {
        // String hearder = requestHeader.nextElement();
        // Logger.error("request.getHeaderNames = " + hearder);
        // Logger.error("request.getHeadervalues = " + request.getHeader(hearder));
        // }

        String ip = request.getHeader("X-FORWARDED-FOR");

        if (ip == null || ip.contentEquals("")) {
            ip = request.getHeader("Proxy-Client-IP");
        }

        if (ip == null || ip.contentEquals("")) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }

        if (ip == null || ip.contentEquals("")) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }

        if (ip == null || ip.contentEquals("")) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }

        if (ip == null || ip.contentEquals("")) {
            ip = request.getRemoteAddr();
        }

        return ip;
    }

    /**
     * 사용자의 USER-AGENT 문자열 가져오기
     *
     * @return 현재 요청(HttpServletRequest)에 대한 USER-AGENT를 반환
     */
    public String getUserAgent() {
        HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
        return request.getHeader("USER-AGENT");
    }

    /**
     * 연속된 문자가 연속으로 4자리 이상인지 여부 체크
     *
     * @param str 체크할 문자열
     * @return 연속 4자리 이상 문자열이 있는 경우 true, 그렇지 않으면 false를 반환
     */
    public boolean continuousStr(String str) {

        int limit = 4;

        if (str == null || str.isEmpty() || str.length() < limit) {
            return false;
        }

        for (int i = 0; i < str.length() - (limit - 1); i++) {

            int c1 = str.charAt(i);
            int c2 = str.charAt(i + 1);
            int c3 = str.charAt(i + 2);
            int c4 = str.charAt(i + 3);

            if (c1 + 1 == c2 && c1 + 2 == c3 && c1 + 3 == c4) {
                return true;
            }
        }

        return false;
    }

    /**
     * 동일한 문자가 연속으로 3자리 이상인지 여부 체크
     *
     * @param str 체크할 문자열
     * @return 동일한 문자가 연속으로 3자리 이상 있는 경우 true, 그렇지 않으면 false를 반환
     */
    public boolean sameStr(String str) {
        for (int idx = 0; idx < str.length() - 2; idx++) {
            if (str.charAt(idx) == str.charAt(idx + 1) && str.charAt(idx + 1) == str.charAt(idx + 2)) {
                return true;
            }
        }

        return false;
    }

    /**
     * 페이징 정보 구하기
     *
     * @param pageNo
     * @param pageSize
     * @param totalCount
     * @param queryString
     * @return
     */
    public Map<String, Object> paging(Integer pageNo, Integer pageSize, Integer totalCount, String queryString) {

        // 변수 선언
        int startPageNo = 0;
        int endPageNo = 0;
        int maxPageNo = 0;

        Integer tPageNo = pageNo;
        Integer tPageSize = pageSize;
        Integer tTotalCount = totalCount;
        String tQueryString = queryString;

        // 페이지 번호
        if (tPageNo == null || tPageNo == 0) {
            tPageNo = 1;
        }

        // 페이지 사이즈
        if (tPageSize == null || tPageSize == 0) {
            tPageSize = 10;
        }

        // 전체 갯수
        if (tTotalCount == null || tTotalCount == 0) {
            tTotalCount = 0;
        }

        // 출력할 시작 페이지 번호 계산
        startPageNo = Math.floorDiv(tPageNo - 1, 10) * 10 + 1;

        // 출력할 종료 페이지 번호 계산
        endPageNo = (int) Math.ceil((double) tPageNo / 10.0) * 10;
        maxPageNo = (int) Math.ceil((double) tTotalCount / (double) tPageSize);

        // 최대 페이지 번호가 0인 경우 1로 세팅
        if (maxPageNo == 0)
            maxPageNo = 1;

        // 종료 페이지 번호가 최대 페이지 번호보다 클 경우 최대 페이지 번호를 종료페이지 번호로 셋팅
        if (maxPageNo < endPageNo) {
            endPageNo = maxPageNo;
        }

        // 쿼리스트링 가공
        if (tQueryString == null || tQueryString.length() == 0) {
            tQueryString = "?";
        } else if (tQueryString.length() > 0 && tQueryString.indexOf("?") == -1) {
            tQueryString = "?" + tQueryString + "&";
        } else {
            tQueryString += "&";
        }

        // 결과 데이터 생성 및 반환
        Map<String, Object> model = new HashMap<>();
        model.put("pageNo", tPageNo); // 페이지 번호
        model.put("pageSize", tPageSize); // 페이지 사이즈
        model.put("totalCount", tTotalCount); // 전체 갯수
        model.put("queryString", tQueryString); // 쿼리스트링
        model.put("startPageNo", startPageNo); // 시작페이지번호
        model.put("endPageNo", endPageNo); // 종료페이지번호
        model.put("maxPageNo", maxPageNo); // 최대페이지번호

        return model;
    }

    /*
     * object(dto, vo) to queryString 처리
     */
    public static String convertVoToQueryString(Class clazz, Object o) {
        StringBuilder queryStringBuilder = new StringBuilder();
        final Map<String, String> queryParams = new LinkedHashMap<>();

        try {
            for (Field f : clazz.getDeclaredFields()) {
                f.setAccessible(true);
                if (ObjectUtils.isEmpty(f.get(o)))
                    continue;
                queryParams.put(f.getName(), String.valueOf(f.get(o)));
            }
            Class superClass = clazz.getSuperclass();
            if (superClass != null) {
                for (Field f : superClass.getDeclaredFields()) {
                    f.setAccessible(true);
                    if (ObjectUtils.isEmpty(f.get(o)))
                        continue;
                    queryParams.put(f.getName(), String.valueOf(f.get(o)));
                }
            }
            for (Map.Entry<String, String> entry : queryParams.entrySet()) {
                queryStringBuilder.append(entry.getKey());
                queryStringBuilder.append("=");
                queryStringBuilder.append(entry.getValue());
                queryStringBuilder.append("&");
            }
        } catch (IllegalArgumentException e) {

        } catch (IllegalAccessException e) {

        }
        final String queryString = queryStringBuilder.toString();
        return "?" + queryString.substring(0, queryString.length() - 1);
    }

    public boolean isOnlyNumber(CharSequence value) {
        if (value == null || value.length() == 0) {
            return false;
        }

        CharBuffer buffer = CharBuffer.wrap(value);

        while (buffer.hasRemaining()) {
            char c = buffer.get();
            if (!(c > 47 && c < 58)) {
                return false;
            }
        }
        return true;

    }

    /**
     * 파라미터로 전달받은 생년월일을 연령대로 변환
     * 
     * @param birthYear - 생년월일(YYYY)
     * @return Integer - 연령대(20대 이하, 30대, 40대, 50대, 60대 이상)
     */
    public Integer getBirthYearToAge(Integer birthYear) {

        Integer result = null;

        if (ObjectUtils.isEmpty(birthYear))
            return null;

        LocalDateTime calculationDate = LocalDateTime.now()
            .minusYears(birthYear);

        Integer calculationYear = calculationDate.getYear();

        if (calculationYear < 30) {
            result = 20;
        } else if (calculationYear < 40) {
            result = 30;
        } else if (calculationYear < 50) {
            result = 40;
        } else if (calculationYear < 60) {
            result = 50;
        } else {
            result = 60;
        }

        return result;
    }

    public static <T> List<T> deduplication(final List<T> list, Function<? super T, ?> key) {
        return list.stream()
            .filter(deduplication(key))
            .collect(Collectors.toList());
    }

    private static <T> Predicate<T> deduplication(Function<? super T, ?> key) {
        final Set<Object> set = ConcurrentHashMap.newKeySet();
        return predicate -> set.add(key.apply(predicate));
    }

    /**
     * 파일 URL 생성
     * 
     * @param url
     * @param path
     * @param name
     * @return
     */
    public String generateUrlPath(String url, String path, String name) {

        if (url == null || path == null || name == null) {
            return null;
        } else {
            String fileUrl = url;

            if (fileUrl.lastIndexOf("/") == fileUrl.length() - 1) {
                fileUrl = fileUrl.substring(0, fileUrl.length() - 1);
            }
            if (path.indexOf("/") != 0) {
                fileUrl += "/" + path;
            } else {
                fileUrl += path;
            }
            if (fileUrl.lastIndexOf("/") == fileUrl.length() - 1) {
                fileUrl = fileUrl.substring(0, fileUrl.length() - 1);
            }
            if (name.indexOf("/") != 0) {
                fileUrl += "/" + name;
            } else {
                fileUrl += name;
            }
            return fileUrl;
        }
    }

}
