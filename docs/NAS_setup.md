# Synology NAS Spring Boot 배포 기록 (NAS.md)

## 1. 목표
- Spring Boot 백엔드(JAR)를 Synology NAS에서 Docker로 실행
- 외부망에서도 HTTPS로 접근 가능하게 Reverse Proxy 구성

---

## 2. NAS 디렉토리 구성

```bash
/volume1/docker/jindamhair-backend/
 ├── app.jar
 ├── Dockerfile
```

---

## 3. Dockerfile 작성

✅ 반드시 `openjdk:17` 대신 `eclipse-temurin` 사용

```dockerfile
FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY app.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

## 4. Docker Build (NAS root 권한 필요)

### 4.1 Docker 소켓 권한 문제

```bash
ls -l /var/run/docker.sock
# srw-rw---- 1 root root ...
```

→ manage 계정은 접근 불가  
→ root로 실행해야 함

---

### 4.2 이미지 빌드

```bash
cd /volume1/docker/jindamhair-backend
docker build -t my-spring-app .
```

성공 시:

```
Successfully tagged my-spring-app:latest
```

---

## 5. Spring Boot 컨테이너 실행

### 5.1 기본 실행

```bash
docker run -d   --name springboot-app   -p 8080:8080   my-spring-app
```

---

## 6. Profile(prod) 실행 오류 해결

### 6.1 오류 메시지

```
Could not resolve placeholder 'spring.profiles.active'
classpath:logger/logback-${spring.profiles.active}-spring.xml
```

→ active profile 설정이 없어서 logback 로딩 실패

---

### 6.2 해결: prod 프로파일 지정 실행

```bash
docker rm -f springboot-app

docker run -d   --name springboot-app   -p 8080:8080   my-spring-app   --spring.profiles.active=prod
```

---

### 6.3 정상 실행 로그

```
The following 1 profile is active: "prod"
Tomcat started on port 8080
Started JindamApplication in ~10 seconds
```

---

## 7. 외부 접속 설정

## 7.1 Synology DDNS 사용

✅ Synology 기본 제공 주소:

```
api.velysound.synology.me
```

Reverse Proxy 적용 후 외부 접속 가능:

```
http://api.velysound.synology.me
```

---

## 7.2 Reverse Proxy 설정 (DSM)

DSM → 제어판 → 로그인 포털 → 고급 → **역방향 프록시**

### 설정값

| 구분 | 값 |
|------|---|
| 소스 프로토콜 | HTTP 또는 HTTPS |
| 소스 Host | api.velysound.synology.me |
| 소스 Port | 80 (HTTP) / 443 (HTTPS) |
| 대상 프로토콜 | HTTP |
| 대상 Host | localhost |
| 대상 Port | 8080 |

---

## 7.3 HTTPS 적용 (권장)

### 인증서 발급

DSM → 보안 → 인증서 → 추가  
✅ Let's Encrypt 선택

도메인:

```
api.velysound.synology.me
```

---

## 7.4 공유기 포트포워딩 필요

외부 서비스 운영 시:

| 외부포트 | NAS포트 |
|---------|--------|
| 80 | 80 |
| 443 | 443 |

---

## 8. 도메인(api.jindamhair.com)이 안 되는 이유

✅ `api.velysound.synology.me` 는 Synology DDNS에 연결되어 있음  
❌ `api.jindamhair.com` 은 DNS 설정이 되어 있지 않으면 접속 불가

---

## 9. 운영 권장 구조

✅ 최종 추천 구성:

```
외부 HTTPS (443)
   ↓
Synology Reverse Proxy
   ↓
Docker Spring Boot (8080)
   ↓
PostgreSQL (15432)
```

---

## 10. 자주 쓰는 명령어

### 컨테이너 상태 확인

```bash
docker ps
```

### 로그 확인

```bash
docker logs -f springboot-app
```

### 재시작

```bash
docker restart springboot-app
```

### 삭제 후 재실행

```bash
docker rm -f springboot-app
docker run -d ...
```

---

# ✅ 완료
NAS에서 Spring Boot Docker 배포 성공 + prod 프로파일 적용 완료.
