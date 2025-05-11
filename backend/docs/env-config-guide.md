# 환경 변수 및 설정 관리 가이드

이 문서는 백엔드 서비스의 환경 변수 및 설정 관리에 대한 표준과 모범 사례를 설명합니다.

## 개요

우리 프로젝트는 다양한 마이크로서비스로 구성되어 있으며, 일관된 방식으로 설정을 관리하기 위해 중앙화된 설정 시스템을 사용합니다. 이 시스템은 다음과 같은 특징을 가집니다:

- 환경별 설정 파일 (`development`, `test`, `production`)
- 로컬 개발 설정 지원 (`.env.local`)
- 설정 값 타입 변환 및 검증
- 서비스별로 그룹화된 설정값
- 필수 환경 변수 검증

## 환경 변수 파일 구조

환경 변수는 다음과 같은 파일 구조로 관리됩니다:

```
/Infrastructure/
  ├── .env.development      # 개발 환경 설정
  ├── .env.test             # 테스트 환경 설정
  ├── .env.production       # 운영 환경 설정
  ├── .env                  # 모든 환경 공통 설정
  └── .env.local            # 로컬 개발 설정 (Git에 커밋되지 않음)
```

**로드 우선순위**:
1. `.env.{NODE_ENV}` (환경별 기본 설정)
2. `.env` (공통 설정)
3. `.env.local` (개발자별 로컬 설정, Git에 커밋되지 않음)

## 환경 변수 명명 규칙

환경 변수는 다음과 같은 명명 규칙을 따릅니다:

1. **대문자와 밑줄**: 모든 환경 변수는 대문자와 밑줄(`_`)을 사용합니다.
   ```
   DATABASE_URL    (O)
   databaseUrl     (X)
   database-url    (X)
   ```

2. **서비스별 접두사**: 서비스별 설정은 서비스 이름을 접두사로 사용합니다.
   ```
   AUTH_SERVICE_PORT
   PAYMENT_API_KEY
   ```

3. **그룹화**: 관련 설정은 동일한 접두사를 사용해 그룹화합니다.
   ```
   DB_HOST
   DB_PORT
   DB_USERNAME
   DB_PASSWORD
   ```

4. **중복 방지**: 다른 변수와 충돌하지 않는 고유한 이름을 사용합니다.

## 설정 접근 방법

`Shared/config` 모듈을 통해 설정에 접근합니다:

```javascript
const config = require('../../../Shared/config');

// 기본 설정 접근
const port = config.server.auth.port;
const dbConfig = config.db;

// 환경 확인
if (config.app.isDev) {
  // 개발 환경 전용 코드
}

// 직접 환경 변수 접근 (필요한 경우)
const customValue = config.get('CUSTOM_VARIABLE', 'default_value');
const numberValue = config.get('NUMBER_VALUE', 0, 'number');
const boolValue = config.get('FEATURE_FLAG', false, 'boolean');
const arrayValue = config.get('ALLOWED_ORIGINS', '*', 'array');
```

## 환경별 설정 방법

### 개발 환경 (Development)

개발 환경은 로컬 개발 시 사용되는 설정으로, 디버깅과 개발 편의성을 위한 설정이 포함됩니다:

- 상세한 로깅 (`LOG_LEVEL=debug`)
- 모든 출처에서의 CORS 허용 (`CORS_ALLOWED_ORIGINS=*`)
- 자동 DB 스키마 업데이트 (`DB_SYNC_ALTER=true`)
- 테스트 모드 외부 API 연결

### 테스트 환경 (Test)

테스트 환경은 자동화된 테스트 실행을 위한 설정입니다:

- 최소한의 로깅 (`LOG_LEVEL=warn`)
- 테스트용 별도 데이터베이스 (`DB_NAME=homecleaning_test`)
- 테스트용 모의(mock) API 엔드포인트
- 성능 보다는 격리성 중시

### 운영 환경 (Production)

운영 환경 설정은 성능, 보안 및 안정성에 중점을 둡니다:

- 중요 정보만 로깅 (`LOG_LEVEL=info`)
- 보안을 위한 CORS 제한 (`CORS_ALLOWED_ORIGINS=https://yourdomain.com`)
- 성능 최적화 설정 (연결 풀, 캐시 등)
- DB 스키마 자동 업데이트 비활성화 (`DB_SYNC_ALTER=false`)

## 민감 정보 관리

민감한 정보(비밀번호, API 키 등)는 다음과 같이 관리합니다:

1. `.env.example` 파일에는 실제 민감 정보를 포함하지 않고 예시만 제공
2. 운영 환경에서는 환경 변수 또는 보안 저장소(예: AWS Secrets Manager)를 통해 제공
3. 로컬 개발 환경에서는 `.env.local` 파일(Git에 커밋되지 않음)에 저장

## 환경 변수 검증

설정의 유효성을 검증하기 위한 방법:

```javascript
// 필수 환경 변수 검증
config.validateRequired([
  'JWT_SECRET',
  'DB_PASSWORD',
  'DB_HOST',
]);

// 특정 조건에서만 필수인 경우
if (config.services.storage.type === 's3') {
  config.validateRequired([
    'AWS_ACCESS_KEY_ID',
    'AWS_SECRET_ACCESS_KEY',
    'AWS_S3_BUCKET',
  ]);
}
```

## 모범 사례

1. **환경별 설정 분리**: 개발, 테스트, 운영 환경에 적합한 설정을 분리합니다.
2. **기본값 제공**: 모든 설정에 합리적인 기본값을 제공합니다.
3. **타입 지정**: 설정 값의 타입을 명시적으로 지정합니다. (문자열, 숫자, 불리언 등)
4. **주석 작성**: 환경 변수 파일에 충분한 주석을 작성하여 각 설정의 목적을 설명합니다.
5. **설정 변경 최소화**: 실행 중인 서비스의 설정 변경은 최소화합니다.
6. **설정 문서화**: 모든 설정 옵션을 문서화합니다.

## 환경 변수 목록

아래는 시스템에서 사용되는 주요 환경 변수 목록입니다:

### 기본 설정
- `NODE_ENV`: 실행 환경 (`development`, `test`, `production`)
- `LOG_LEVEL`: 로그 레벨 (`error`, `warn`, `info`, `http`, `debug`)
- `API_TIMEOUT`: API 요청 타임아웃 (밀리초)
- `CORS_ALLOWED_ORIGINS`: CORS 허용 도메인 (쉼표로 구분)

### 서버 설정
- `{SERVICE}_PORT`: 각 서비스의 포트 번호 (예: `GATEWAY_PORT`, `AUTH_SERVICE_PORT` 등)

### 데이터베이스 설정
- `DB_HOST`: 데이터베이스 호스트
- `DB_PORT`: 데이터베이스 포트
- `DB_USERNAME`: 데이터베이스 사용자 이름
- `DB_PASSWORD`: 데이터베이스 비밀번호
- `DB_NAME`: 데이터베이스 이름
- `DB_DIALECT`: 데이터베이스 유형 (`postgres`, `mysql` 등)
- `DB_POOL_MAX`: 최대 연결 풀 크기
- `DB_LOGGING`: SQL 쿼리 로깅 활성화 여부

### 인증 설정
- `JWT_SECRET`: JWT 서명 비밀키
- `JWT_ALGORITHM`: JWT 알고리즘 (`HS256`, `RS256` 등)
- `JWT_ACCESS_EXPIRES_IN`: 액세스 토큰 만료 시간
- `JWT_REFRESH_EXPIRES_IN`: 리프레시 토큰 만료 시간

### 캐시 설정
- `CACHE_ENABLED`: 캐시 활성화 여부
- `REDIS_HOST`: Redis 호스트
- `REDIS_PORT`: Redis 포트
- `REDIS_PASSWORD`: Redis 비밀번호
- `CACHE_TTL`: 기본 캐시 TTL (초)

### 외부 서비스 설정
- `PAYMENT_API_URL`: 결제 API URL
- `PAYMENT_API_KEY`: 결제 API 키
- `STORAGE_TYPE`: 파일 저장소 타입 (`local`, `s3`)
- `AWS_S3_BUCKET`: S3 버킷 이름
- `PUSH_ENABLED`: 푸시 알림 활성화 여부

자세한 환경 변수 목록은 `.env.example` 파일을 참조하세요.