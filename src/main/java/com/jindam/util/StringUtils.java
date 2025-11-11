package com.jindam.util;

import java.util.List;
import java.util.StringJoiner;

import org.apache.commons.lang3.StringEscapeUtils;
import org.springframework.lang.Nullable;

public class StringUtils {

    private static final char FOLDER_SEPARATOR_CHAR = '/';

    private static final char EXTENSION_SEPARATOR = '.';

    /**
     * 문자열이 null이거나 빈 문자열인지 확인합니다.
     *
     * @param str 확인할 문자열
     * @return 문자열이 null이거나 빈 문자열이면 true, 그렇지 않으면 false
     */
    public static boolean isNullEmpty(String str) {
        return str == null || str.trim()
            .isEmpty();
    }

    /**
     * 문자열이 null이거나 빈 문자열이 아닌지 확인합니다.
     *
     * @param str 확인할 문자열
     * @return 문자열이 null이거나 빈 문자열이 아니면 true, 그렇지 않으면 false
     */
    public static boolean isNotNullEmpty(String str) {
        return !isNullEmpty(str);
    }

    /**
     * 두 문자열을 null-safe 하게 비교합니다.
     *
     * 둘 다 null 이면 true <br/>
     * 하나만 null 이면 false <br/>
     * 둘 다 non-null 이면 str1.equals(str2) 결과
     *
     * @param str1 첫 번째 문자열
     * @param str2 두 번째 문자열
     * @return 두 문자열이 같으면 true, 아니면 false
     */
    public static boolean equals(String str1, String str2) {
        return (str1 == null) ? (str2 == null) : str1.equals(str2);
    }

    /**
     * 두 문자열이 null-safe 하게 같지 않은지 비교합니다.
     *
     * 둘 다 null 이면 false <br/>
     * 하나만 null 이면 true <br/>
     * 둘 다 non-null 이면 !str1.equals(str2) 결과 <br/>
     *
     * @param str1 첫 번째 문자열
     * @param str2 두 번째 문자열
     * @return 두 문자열이 같지 않으면 true, 같으면 false
     */
    public static boolean notEquals(String str1, String str2) {
        return !equals(str1, str2);
    }

    /**
     * 문자열을 지정한 문자열로 시작하는지 확인합니다.
     *
     * @param str 확인할 문자열
     * @param prefix 시작 문자열
     * @return 지정한 문자열로 시작하면 true, 그렇지 않으면 false
     */
    public static boolean startsWith(String str, String prefix) {
        if (isNullEmpty(str))
            return false;

        return str.startsWith(prefix);
    }

    /**
     * 문자열을 지정한 문자열로 끝나는지 확인합니다.
     *
     * @param str 확인할 문자열
     * @param suffix 끝 문자열
     * @return 지정한 문자열로 끝나면 true, 그렇지 않으면 false
     */
    public static boolean endsWith(String str, String suffix) {
        if (isNullEmpty(str))
            return false;

        return str.endsWith(suffix);
    }

    /**
     * 주어진 문자열에서 처음부터 주어진 끝 인덱스(Exclusive) 전까지 자릅니다.
     *
     * @param input 원본 문자열
     * @param endIndex 끝 인덱스 (0이하일 경우 빈 문자열 반환, length 초과 시 전체 문자열 반환)
     * @return 잘라진 문자열 (input이 null인 경우 null 반환)
     */
    public static String substring(String input, int endIndex) {
        if (input == null) {
            return null;
        }
        int end = Math.min(endIndex, input.length());
        if (end <= 0) {
            return "";
        }
        return input.substring(0, end);
    }

    /**
     * 주어진 문자열에서 시작 인덱스(Inclusive)부터 끝 인덱스(Exclusive) 전까지 자릅니다.
     *
     * @param input 원본 문자열
     * @param startIndex 시작 인덱스 (0 미만이면 0으로 처리)
     * @param endIndex 끝 인덱스 (length 초과 시 length로 처리)
     * @return 잘라진 문자열 (input이 null인 경우 null 반환)
     */
    public static String substring(String input, int startIndex, int endIndex) {
        if (input == null) {
            return null;
        }
        int length = input.length();
        int start = Math.max(0, Math.min(startIndex, length));
        int end = Math.max(start, Math.min(endIndex, length));
        return input.substring(start, end);
    }

    /**
     * 주어진 문자열에서 특정 문자열(target)을 정규표현식(regex)으로 해석하여 매칭된 모든 부분을 replacement로 대체합니다.
     *
     * @param input 원본 문자열
     * @param target 정규식 패턴 문자열 (null 또는 빈 문자열인 경우 input 반환)
     * @param replacement 대체할 문자열 (null인 경우 빈 문자열로 대체)
     * @return 대체 결과 문자열 (input이 null인 경우 null 반환)
     */
    public static String replaceAll(String input, String target, String replacement) {
        if (input == null) {
            return null;
        }
        if (target == null || target.isEmpty()) {
            return input;
        }
        String repl = replacement == null ? "" : replacement;
        return input.replaceAll(target, repl);
    }

    /**
     * 문자열 리스트를 지정한 구분자로 결합합니다.
     *
     * @param list 문자열 리스트
     * @param delimiter 구분자
     * @return 결합된 문자열
     */
    public static String join(List<String> list, String delimiter) {
        StringJoiner joiner = new StringJoiner(delimiter);
        for (String str : list) {
            if (isNotNullEmpty(str)) {
                joiner.add(str);
            }
        }
        return joiner.toString();
    }

    /**
     * 모든 공백을 제거하는 메소드
     *
     * @param input 입력 문자열
     * @return 공백이 제거된 문자열
     */
    public static String removeAllSpaces(String input) {
        if (input == null) {
            return null;
        }
        return input.replaceAll("\\s+", "");
    }

    /**
     * 모든 공백을 제거하는 메소드 (Integer 입력)
     *
     * @param input 입력 정수
     * @return 공백이 제거된 문자열
     */
    public static String removeAllSpaces(Integer input) {
        if (input == null) {
            return null;
        }
        // Integer를 String으로 변환한 후 공백 제거
        return removeAllSpaces(input.toString());
    }

    /**
     * 입력된 문자열의 HTML 엔티티를 디코딩하는 메소드.
     *
     * @description 일반적으로 2중첩까지 escape가 발생함.
     * @param input HTML 엔티티가 포함된 입력 문자열
     * @return 디코딩된 문자열 (입력 값이 null인 경우 null 반환)
     */
    public static String unescapeHtml(String input) {
        if (input == null) {
            return null;
        }

        String decoded = input;

        for (int i = 0; i < 5; i++) {
            String temp = StringEscapeUtils.unescapeHtml3(decoded);
            temp = StringEscapeUtils.unescapeHtml4(decoded);

            temp = temp.replace("&apos;", "'");
            temp = temp.replace("&amp;", "&");
            temp = temp.replace("&gtdot;", "≳"); // HTML5 추가 기호
            temp = temp.replace("&lesdot;", "⩿");
            temp = temp.replace("&rarr;", "→");
            temp = temp.replace("&harr;", "↔");
            temp = temp.replace("&NewLine;", "\n");
            temp = temp.replace("&nabla;", "∇"); // 수학 기호
            temp = temp.replace("&notin;", "∉");
            temp = temp.replace("&infin;", "∞");
            temp = temp.replace("&prod;", "∏");

            if (temp.equals(decoded)) {
                break; // 더 이상 디코딩할 필요가 없으면 중단
            }
            decoded = temp;
        }

        return decoded;
    }

    /**
     * 입력된 문자열을 HTML 엔티티로 인코딩하는 메소드.
     *
     * @description 일반적으로 2중첩까지 인코딩이 필요하나, 최대 5회 반복 적용
     * @param input 원시 문자열
     * @return 인코딩된 문자열 (입력 값이 null인 경우 null 반환)
     */
    public static String escapeHtml(String input) {
        if (input == null) {
            return null;
        }

        String encoded = input;

        for (int i = 0; i < 5; i++) {
            // 주요 HTML4/3 엔티티 인코딩
            String temp = StringEscapeUtils.escapeHtml4(encoded);

            // Apache Commons가 기본으로 escape하지 않는 커스텀 엔티티
            temp = temp.replace("'", "&apos;");
            temp = temp.replace("≳", "&gtdot;"); // HTML5 추가 기호
            temp = temp.replace("⩿", "&lesdot;");
            temp = temp.replace("→", "&rarr;");
            temp = temp.replace("↔", "&harr;");
            temp = temp.replace("\n", "&NewLine;");
            temp = temp.replace("∇", "&nabla;");
            temp = temp.replace("∉", "&notin;");
            temp = temp.replace("∞", "&infin;");
            temp = temp.replace("∏", "&prod;");

            // 더 이상 변화가 없으면 중단
            if (temp.equals(encoded)) {
                break;
            }
            encoded = temp;
        }

        return encoded;
    }

    /**
     * 주어진 Java 리소스 경로에서 파일명을 추출합니다. <br/>
     * 예: {@code "mypath/myfile.txt" &rarr; "myfile.txt"}.
     *
     * @param path 파일 경로 (값이 {@code null}일 수 있음)
     * @return 추출된 파일명 또는 파일명이 없을 경우 {@code null}
     */
    @Nullable
    public static String getFilename(@Nullable String path) {
        if (path == null) {
            return null;
        }

        int separatorIndex = path.lastIndexOf(FOLDER_SEPARATOR_CHAR);
        return (separatorIndex != -1 ? path.substring(separatorIndex + 1) : path);
    }

    /**
     * 주어진 Java 리소스 경로에서 파일 확장자를 추출합니다. <br/>
     * 예: "mypath/myfile.txt" &rarr; "txt".
     *
     * @param path 파일 경로 (값이 {@code null}일 수 있음)
     * @return 추출된 파일 확장자 또는 확장자가 없을 경우 {@code null}
     */
    @Nullable
    public static String getFilenameExtension(@Nullable String path) {
        if (path == null) {
            return null;
        }

        int extIndex = path.lastIndexOf(EXTENSION_SEPARATOR);
        if (extIndex == -1) {
            return null;
        }

        int folderIndex = path.lastIndexOf(FOLDER_SEPARATOR_CHAR);
        if (folderIndex > extIndex) {
            return null;
        }

        return path.substring(extIndex + 1);
    }

    /**
     * 카멜 케이스를 스네이크 케이스로 변환하는 메소드 <br/>
     * 예: myVariableName → my_variable_name
     *
     * @param input 카멜 케이스 문자열
     * @return 스네이크 케이스 문자열
     */
    public static String camelToSnake(String input) {
        return camelToSnake(input, false);
    }

    /**
     * 카멜 케이스를 스네이크 케이스로 변환하는 메소드 <br/>
     * 예: myVariableName → my_variable_name
     *
     * @param input 카멜 케이스 문자열
     * @return 스네이크 케이스 문자열
     */
    public static String camelToSnake(String input, boolean isLower) {
        if (input == null || input.isEmpty()) {
            return input;
        }

        if (isLower)
            input = input.toLowerCase();

        return input//
            .replaceAll("([a-zA-Z])([0-9])", "$1_$2") // 문자 + 숫자 사이에 "_" 추가
            .replaceAll("([0-9])([a-zA-Z])", "$1_$2") // 숫자 + 문자 사이에 "_" 추가
            .replaceAll("([a-z])([A-Z])", "$1_$2") // 소문자 + 대문자 사이에 "_" 추가
            .toLowerCase();
    }

    /**
     * 스네이크 케이스를 카멜 케이스로 변환하는 메소드 <br/>
     * 예: my_VARIABLE_name → myVariableName
     *
     * @param input 스네이크 케이스 문자열
     * @return 카멜 케이스 문자열
     */
    public static String snakeToCamel(String input) {
        return snakeToCamel(input, false);
    }

    public static String snakeToCamelToLower(String input) {
        return snakeToCamel(input, true);
    }

    public static String snakeToCamel(String input, boolean isLower) {
        if (input == null || input.isEmpty()) {
            return input;
        }
        String[] parts = input.split("_");
        // 첫 파트는 전부 소문자

        String part0 = parts[0];

        if (isLower)
            part0 = part0.toLowerCase();

        StringBuilder camel = new StringBuilder(part0);

        for (int i = 1; i < parts.length; i++) {
            String part = parts[i];

            if (isLower)
                part = part.toLowerCase();

            // 첫 글자만 대문자, 나머지는 소문자
            camel.append(Character.toUpperCase(part.charAt(0)))
                .append(part.substring(1));
        }
        return camel.toString();
    }

    /**
     * 주어진 문자열의 첫 글자는 대문자, 나머지는 소문자로 변환한다.
     *
     * @param input 영문자·숫자 조합의 문자열 (null 또는 빈 문자열 가능)
     * @return 변환된 문자열, input이 null 또는 빈 문자열이면 그대로 반환
     */
    public static String capitalizeFirstLowerRest(String input) {
        if (input == null || input.isEmpty()) {
            return input;
        }
        // 첫 글자 대문자로
        char first = Character.toUpperCase(input.charAt(0));
        // 나머지 소문자로 (숫자는 변경 없음)
        String rest = input.substring(1)
            .toLowerCase();
        return first + rest;
    }

    /**
     * 주어진 문자열이 리터럴 "null" 이면 실제 null로, 그 외(빈 문자열, 다른 값)은 그대로 반환한다.
     *
     * @param str 검사할 문자열
     * @return str이 "null" 이면 null, 아니면 str 그대로
     */
    public static String replaceNull(String str) {
        if (str == null)
            return str;

        str = str.trim();

        if (str == null || str.isEmpty() || "null".equals(str)) {
            return null;
        }
        return str;
    }

    /**
     * 숫자형(Number) 객체를 null-safe 하게 문자열로 반환.
     *
     * Number(null) → null <br/>
     * Number(x) → x.toString()
     *
     * @param number 변환할 숫자형 객체(Integer, Double, Long 등)
     * @return null 이거나 숫자를 toString() 한 결과
     */
    public static String toStringOrNull(Number number) {
        return number == null ? null : number.toString();
    }

    /**
     * Jsoup 파서를 이용해 HTML 구조를 해석한 뒤 텍스트만 추출합니다.
     *
     * @param html 입력 HTML 문자열 (null 허용)
     * @return 파싱된 순수 텍스트, 입력이 null이면 null 반환
     */
    // public static String stripHtmlWithJsoup(String html) {
    // if (html == null) {
    // return null;
    // }
    // // Jsoup.parse(html).text() 로 HTML 내 텍스트 노드만 취합
    // return Jsoup.parse(html)
    // .text();
    // }

    /**
     * 주어진 문자열의 앞뒤 공백을 제거하고, 끝에 “.0”이 붙어 있으면 제거합니다.
     *
     * @param raw 정규화할 문자열 (null 허용)
     * @return 트림된 문자열에서 단일 “.0”이 제거된 결과, 입력이 null이면 null
     */
    public static String normalizeNumericString(String raw) {
        if (raw == null) {
            return null;
        }
        String s = raw.trim();
        return s.endsWith(".0") ? s.substring(0, s.length() - 2) : s;
    }

}