package com.jindam.util;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.BeanUtils;

public class Utils {

    public static boolean isEmpty(Long v) {
        return v == null || v <= 0;
    }

    public static boolean isNotEmpty(Long v) {
        return !isEmpty(v);
    }

    public static boolean isEmpty(String str) {
        return StringUtils.isEmpty(str);
    }

    public static boolean isNotEmpty(String str) {
        return !isEmpty(str);
    }

    public static List<Long> parseLongList(List<String> items) {
        return items.stream()
            .map(x -> Long.parseLong(x))
            .collect(Collectors.toList());
    }

    // public static String decryptAES(String text) {
    // if (StringUtils.isEmpty(text))
    // return text;
    // try {
    // return AES256.decrypt(text.replaceAll("\r", "")
    // .replaceAll("\n", ""));
    // } catch (Exception ex) {
    // System.out.println("AES ERR " + text);
    // return text;
    // }
    // }

    public static String removeHTML(String data) {
        String output = data;
        if (output == null)
            return null;
        output = output.replaceAll("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>", "")
            .trim();
        output = output.replaceAll("&nbsp;", " ");
        output = output.replaceAll("&lt;", "");
        output = output.replaceAll("&gt;", "");
        output = output.replaceAll("&middot;", "");
        output = output.replaceAll("\\s+", " ");
        return output;
    }

    public static String removeImgTags(String htmlContent) {
        if (htmlContent == null || htmlContent.isEmpty()) {
            return htmlContent;
        }

        // 정규식을 사용하여 <img> 태그를 찾고 제거하기
        String imgTagPattern = "<img\\b[^>]*>"; // 정규식 패턴
        Pattern pattern = Pattern.compile(imgTagPattern, Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(htmlContent);

        // <img> 태그를 빈 문자열로 대체
        return matcher.replaceAll("");
    }

    /**
     * Apache Commons BeanUtils를 사용해 source 객체의 프로퍼티 값을 target 객체로 복사합니다.
     *
     * @param target 복사될 대상 객체 (프로퍼티가 덮어쓰여짐)
     * @param source 프로퍼티 값을 읽어올 원본 객체
     * @param <T> target 객체의 타입
     * @return 복사가 완료된 target 객체
     */
    public static <T> void copyProperties(final T target, final Object source) {
        try {
            // source의 getter 메서드로 값을 읽고,
            // target의 대응되는 setter 메서드에 값을 전달해 프로퍼티를 복사
            BeanUtils.copyProperties(target, source);
        } catch (Exception e) {
            // 복사 과정에서 예외가 발생하면 스택트레이스를 찍고,
            // target은 일부 또는 전혀 복사되지 않은 상태일 수 있지만 일단 반환
            e.printStackTrace();
        }
    }

    /**
     * List 안의 Map 타입이 Map<String,Object> 의 서브타입이면 (예: HashMap, LinkedHashMap 등) 모두 처리 가능합니다.
     *
     * @param rawList snake_case 키를 가진 Map 들의 리스트
     * @return camelCase 키를 가진 새 Map 리스트
     */
    public static List<Map<String, Object>> toCamelCase(List<? extends Map<String, Object>> rawList) {
        return rawList.stream()
            .map(Utils::convertKeys)
            .collect(Collectors.toList());
    }

    public static Map<String, Object> toCamelCase(Map<String, Object> map) {
        return convertKeys(map);
    }

    /**
     * 단일 Map 의 키를 camelCase 로 바꿔서 새 HashMap 에 담아 반환합니다.
     *
     * @param map 원본 Map (HashMap, LinkedHashMap 등 모든 Map)
     * @return camelCase 키를 가진 HashMap
     */
    public static Map<String, Object> convertKeys(Map<String, Object> map) {
        Map<String, Object> result = new HashMap<>(map.size());
        map.forEach((k, v) -> {
            if (k != null && k.startsWith("nc_")) {
                // "nc_"로 시작하면 카멜 케이스 변환 없이 원본 키 사용
                result.put(k, v);
            } else {
                // 그 외엔 underscoreToCamel 적용
                result.put(underscoreToCamel(k), v);
            }
        });
        return result;
    }

    /**
     * snake_case → camelCase 변환
     */
    public static String underscoreToCamel(String input) {
        StringBuilder sb = new StringBuilder(input.length());
        boolean toUpper = false;
        for (char c : input.toCharArray()) {
            if (c == '_') {
                toUpper = true;
            } else {
                sb.append(toUpper ? Character.toUpperCase(c) : Character.toLowerCase(c));
                toUpper = false;
            }
        }
        return sb.toString();
    }

    /**
     * Object를 받아서 Integer로 안전하게 변환하여 반환합니다.
     * 
     * - null 이거나 변환 불가능한 타입인 경우 null 반환 <br/>
     * - Number 타입은 intValue() 이용 <br/>
     * - String 타입은 parseInt 시도 (parse 에 실패할 경우 null) <br/>
     *
     * @param obj 변환 대상 객체
     * @return Integer 값, 변환 불가 시 null
     */
    public static Integer toInteger(Object obj) {
        if (obj == null) {
            return null;
        }

        if (obj instanceof Number) {
            return ((Number) obj).intValue();
        }

        if (obj instanceof String) {
            String str = ((String) obj).trim();
            if (str.isEmpty()) {
                return null;
            }
            try {
                return Integer.parseInt(str);
            } catch (NumberFormatException e) {
                return null;
            }
        }

        // 그 외 타입인 경우 변환 불가로 null 반환
        return null;
    }

    /**
     * Object를 받아서 Double로 안전하게 변환하여 반환합니다.
     * 
     * - null 이거나 변환 불가능한 타입인 경우 null 반환 <br/>
     * - Number 타입은 doubleValue() 이용 <br/>
     * - String 타입은 parseDouble 시도 (parse 에 실패할 경우 null) <br/>
     *
     * @param obj 변환 대상 객체
     * @return Double 값, 변환 불가 시 null
     */
    public static Double toDouble(Object obj) {
        if (obj == null) {
            return null;
        }

        if (obj instanceof Number) {
            return ((Number) obj).doubleValue();
        }

        if (obj instanceof String) {
            String str = ((String) obj).trim();
            if (str.isEmpty()) {
                return null;
            }
            try {
                return Double.parseDouble(str);
            } catch (NumberFormatException e) {
                return null;
            }
        }

        // 그 외 타입인 경우 로그 없이 null 반환
        return null;
    }

    /**
     * Object를 받아서 String으로 안전하게 변환하여 반환합니다.
     * 
     * - null인 경우 null 반환 <br/>
     * - 그 외에는 obj.toString() 결과 반환 <br/>
     *
     * @param obj 변환 대상 객체
     * @return String 값, obj가 null이면 null
     */
    public static String toString(Object obj) {
        if (obj == null) {
            return null;
        }
        return obj.toString();
    }
}
