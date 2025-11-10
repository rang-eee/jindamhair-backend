package com.jindam.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import com.jindam.base.dto.HttpCurlResponseDto;

/**
 * HTTP 통신을 위한 클래스
 */
public class HttpCurl {

    /**
     * 파일 첨부가 없는 HTTP 요청용 오버로드 <br>
     * 상세 설명은 아래 메서드를 참고하세요.
     */
    public HttpCurlResponseDto httpConnection(String targetUrl, String method, Map<String, String> header, String body) throws IOException {
        return httpConnection(targetUrl, method, header, body, (MultipartFile[]) null);
    }

    /**
     * HTTP 통신을 수행하는 메소드
     *
     * @param targetUrl 통신하고자 하는 대상의 URL
     * @param method HTTP 통신에 사용될 메소드
     * @param header Request의 Header에 삽입될 항목, KEY/VALUE 형식의 Hashtable 객체
     * @param body Request의 Body에 삽입될 항목
     * @param files MultipartFile 형식의 가변적 첨부 파일<br>
     * @return HTTP 통신의 결과의 HttpResponse 객체로 반환
     * @exception IOException HTTP 통신 실패 시 해당 예외가 발생
     *
     * <p>
     * * <b>주의</b>: * 파일 첨부가 없는 경우에도 multipart/form-data 요청이 필요한 API(@RequestPart 사용)에는 <br>
     * * files 파라미터를 null이 아닌 빈 배열(new MultipartFile[0])로 전달해야 정상 동작합니다. <br>
     * * files 파라미터가 null이면 application/json 전송으로 처리되어 서버에서 파싱 오류가 발생할 수 있습니다.<br>
     * </p>
     *
     */
    public HttpCurlResponseDto httpConnection(String targetUrl, String method, Map<String, String> header, String body, MultipartFile... files) throws IOException {

        URL url = null;
        HttpURLConnection conn = null;
        BufferedReader bufferedReader = null;
        OutputStreamWriter streamWriter = null;
        StringBuilder stringBuilder = new StringBuilder();
        String charset = "UTF-8";
        String tMethod = method;

        if (targetUrl == null || targetUrl.isEmpty()) {
            throw new IllegalArgumentException("Parameter targetUrl is null.");
        }

        try {
            url = new URL(targetUrl);
            conn = (HttpURLConnection) url.openConnection();
            conn.setUseCaches(false); // 캐시 사용 안 함
            boolean isBodyMethod = "POST".equalsIgnoreCase(tMethod) || "PUT".equalsIgnoreCase(tMethod) || "PATCH".equalsIgnoreCase(tMethod); // 바디 전송 메서드 여부
            boolean isFileUpload = isBodyMethod && files != null; // 파일 업로드 분기 (바디 메서드이면서 files 파라미터가 null이 아닌 경우) ->
            // "&& files.length != 0" 를 추가하지 마세요.(빈 배열이어도 파일 사용시 multipart/form-data 요청)
            boolean hasJsonBody = isBodyMethod && StringUtils.isNotBlank(body); // JSON 바디 전송 분기
            conn.setDoOutput(isFileUpload || hasJsonBody);// 출력 스트림 필요 여부 결정
            conn.setDoInput(true); // GET, POST

            // 요청 방식 설정 (기본값은 GET)
            if (tMethod == null || tMethod.isEmpty()) {
                tMethod = "GET";
            }
            conn.setRequestMethod(tMethod);

            // multipart/form-data 방식일 경우와 일반 JSON 요청 분기 처리
            if (isFileUpload) {
                // multipart 설정
                String boundary = "----WebKitFormBoundary" + Long.toHexString(System.nanoTime());
                String LINE_FEED = "\r\n";
                conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);

                // 추가 헤더
                if (header != null) {
                    for (Map.Entry<String, String> entry : header.entrySet()) {
                        conn.setRequestProperty(entry.getKey(), entry.getValue());
                    }
                }

                OutputStream outputStream = conn.getOutputStream();
                PrintWriter writer = new PrintWriter(new OutputStreamWriter(outputStream, charset), true);

                // JSON 본문 파트 전송
                if (StringUtils.isNotBlank(body)) {
                    writer.append("--")
                        .append(boundary)
                        .append(LINE_FEED);
                    writer.append("Content-Disposition: form-data; name=\"request\"")
                        .append(LINE_FEED);
                    writer.append("Content-Type: application/json; charset=")
                        .append(charset)
                        .append(LINE_FEED);
                    writer.append(LINE_FEED);
                    writer.append(body)
                        .append(LINE_FEED);
                    writer.flush();
                }

                // 파일 파트 전송
                for (MultipartFile file : files) {
                    if (file != null && !file.isEmpty()) {
                        String fileName = file.getOriginalFilename();
                        String contentType = file.getContentType();
                        if (contentType == null)
                            contentType = "application/octet-stream";

                        writer.append("--")
                            .append(boundary)
                            .append(LINE_FEED);
                        writer.append("Content-Disposition: form-data; name=\"files\"; filename=\"")
                            .append(fileName)
                            .append("\"")
                            .append(LINE_FEED);
                        writer.append("Content-Type: ")
                            .append(contentType)
                            .append(LINE_FEED);
                        writer.append(LINE_FEED);
                        writer.flush();

                        InputStream inputStream = file.getInputStream();
                        byte[] buffer = new byte[4096];
                        int bytesRead;
                        while ((bytesRead = inputStream.read(buffer)) != -1) {
                            outputStream.write(buffer, 0, bytesRead);
                        }
                        outputStream.flush();
                        inputStream.close();

                        writer.append(LINE_FEED);
                        writer.flush();
                    }
                }

                // multipart 종료 바운더리
                writer.append("--")
                    .append(boundary)
                    .append("--")
                    .append(LINE_FEED);
                writer.close();

            } else {
                // 일반 application/json 요청
                // Content-Type 헤더 설정
                if (header == null || !header.containsKey("Content-Type")) {
                    conn.setRequestProperty("Content-Type", "application/json");
                }
                if (header == null || !header.containsKey("Accept")) {
                    conn.setRequestProperty("Accept", "application/json");
                }
                if (header == null || !header.containsKey("Cache-Control")) {
                    conn.setRequestProperty("Cache-Control", "no-cache");
                }

                if (header != null) {
                    for (Map.Entry<String, String> entry : header.entrySet()) {
                        conn.setRequestProperty(entry.getKey(), entry.getValue());
                    }
                }

                // POST/PUT 요청 시 Body 전송
                if ((tMethod.equalsIgnoreCase("POST") || tMethod.equalsIgnoreCase("PUT")) && StringUtils.isNotBlank(body)) {
                    streamWriter = new OutputStreamWriter(conn.getOutputStream(), charset);
                    streamWriter.write(body);
                    streamWriter.flush();
                }
            }

            // 응답 처리
            int responseCode = conn.getResponseCode();
            InputStream responseStream = (responseCode == HttpURLConnection.HTTP_OK) ? conn.getInputStream() : conn.getErrorStream();

            bufferedReader = new BufferedReader(new InputStreamReader(responseStream, charset));
            String tempString;
            while ((tempString = bufferedReader.readLine()) != null) {
                stringBuilder.append(tempString)
                    .append("\n");
            }

            HttpCurlResponseDto response = new HttpCurlResponseDto();
            response.setResponseCode(responseCode);
            response.setResponseMessage(conn.getResponseMessage());
            response.setResponseBody(StringUtils.defaultString(stringBuilder.toString()));

            return response;

        } finally {
            if (bufferedReader != null) {
                bufferedReader.close();
            }
            if (streamWriter != null) {
                streamWriter.close();
            }
            if (conn != null) {
                conn.disconnect();
            }
        }
    }
}