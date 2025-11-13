# jindamhair-backend

Java : OpenJdk 17
Springboot : 3.4.11
Build : Gradle 8.14.3
Database : PostgreSql

---

- gadle BOM(Bill of Materials) 명단 목록
./gradlew dependencyManagement


- git config 변경
	$ git config user.name "COLON 이범규"
	$ git config user.email "colon.dev.rang@gmail.com"


- formatter 설정
	- document\java_formatter.xml
	- 각 툴의 저장 시 리포맷 액션 설정


- local 서버 기동
	- profile local로 설정
		spring.profiles.active=local
	- application-local.yml 
		- os type 본인에 맞게 설정
		- os type에 루트 경로를 본인에 맞게 설정


- swagger
	- http://localhost:8080/swagger-ui/index.html#/
	
	
- 문서 경로
	- AS-IS 관리
		- https://docs.google.com/spreadsheets/d/13Xu_fG7qE4kiaEmbtKgCxhuaH9tRjOXBwQvheC7gEkk/edit?gid=525747443#gid=525747443
	- 데이터베이스
		- https://docs.google.com/spreadsheets/d/1mw9Vwwxin5TF0Q0DVQ0Re3jFNjqki82rQvfmfJWfzoY/edit?gid=144105260#gid=144105260
	- 코드정의서
		- https://docs.google.com/spreadsheets/d/1oW-9Ns8h27D7cLKX3XWgJ7A5MCxvKZ_VcwlVkZugUTY/edit?gid=580962851#gid=580962851
		- 공통코드, 오류코드 관리
		- 오류코드는 ApiResultCode.java와 일치 관리 필요