# 로깅 가이드

## 개요

이 문서는 우리 프로젝트의 로깅 시스템 사용법과 모범 사례를 설명합니다. 우리는 통합 로깅 시스템을 구현하여 모든 서비스가 일관된 로그 형식을 사용하도록 합니다.

## 로깅 시스템 특징

- **통합 로거**: 모든 서비스가 동일한 로깅 시스템 사용
- **구조화된 로깅**: JSON 형식으로 로그 저장으로 쉬운 파싱 및 분석
- **로그 레벨**: 환경에 따른 자동 로그 레벨 조정
- **요청 추적**: 고유 요청 ID 부여로 분산 시스템에서의 요청 추적 가능
- **컨텍스트 유지**: 요청, 사용자 ID 등 컨텍스트 정보 포함
- **소스 위치 추적**: 로그가 발생한 파일 및 라인 번호 자동 추적

## 로그 레벨 가이드

로그 레벨은 정보의 중요도를 나타냅니다:

- **error (0)**: 심각한 문제, 서비스 기능이 손상됨 (예: 데이터베이스 연결 불가, API 전체 실패)
- **warn (1)**: 잠재적 문제, 정상 작동하지만 주의 필요 (예: API 응답 속도 저하, 재시도 발생)
- **info (2)**: 중요한 정보, 일반적인 작업 진행 상황 (예: 서비스 시작/종료, 중요 기능 완료)
- **http (3)**: HTTP 요청/응답 정보 (예: 요청 시작, 응답 완료)
- **debug (4)**: 디버깅용 상세 정보 (예: 함수 호출, 변수 값, 내부 처리 흐름)

## 사용 방법

### 기본 로깅

```javascript
const logger = require('../../../Shared/logger');

// 기본 로깅
logger.debug('디버깅 메시지');
logger.info('정보 메시지');
logger.warn('경고 메시지');
logger.error('에러 메시지');
logger.http('HTTP 관련 메시지');

// 메타데이터와 함께 로깅
logger.info('사용자 로그인 성공', { userId: '123', role: 'admin' });

// 에러 객체 로깅 (스택 트레이스 자동 포함)
try {
  // 코드...
} catch (error) {
  logger.error(error);
}
```

### 요청 컨텍스트 로깅

Express 미들웨어를 통해 요청 ID를 자동으로 생성하고 로그에 포함시킵니다:

```javascript
// Express 앱에 미들웨어 추가
const logger = require('../../../Shared/logger');
app.use(logger.middleware);

// 라우트 핸들러에서 요청 컨텍스트 로깅 사용
app.get('/api/users', (req, res) => {
  // 요청 ID가 자동으로 포함됨
  logger.request(req).info('사용자 목록 조회 시작');
  
  // 비즈니스 로직...
  
  logger.request(req).info('사용자 목록 조회 완료', { count: users.length });
  res.json(users);
});
```

## 로그 파일 위치

로그 파일은 다음 위치에 저장됩니다:

- `logs/combined.log`: 모든 로그 메시지
- `logs/error.log`: 에러 로그만 포함
- `logs/YYYY-MM-DD-combined.log`: 날짜별 모든 로그
- `logs/YYYY-MM-DD-error.log`: 날짜별 에러 로그

## 모범 사례

1. **적절한 로그 레벨 사용**: 정보의 중요도에 맞는 로그 레벨 사용
   - 프로덕션에서는 `info` 이상의 로그만 기록됨
   - 디버그 정보는 `debug` 레벨 사용

2. **구조화된 정보 포함**: 로그 메시지와 함께 관련 정보를 객체로 전달
   ```javascript
   // 좋은 예
   logger.info('상품 추가됨', { productId: '123', name: '스마트폰', price: 1000000 });
   
   // 나쁜 예
   logger.info(`상품 추가됨: ID=${productId}, 이름=${name}, 가격=${price}`);
   ```

3. **개인정보 보호**: 로그에 개인정보 또는 민감한 정보를 포함하지 않음
   - 비밀번호, 토큰, 신용카드 정보 등은 절대 로깅하지 말 것
   - 개인정보는 마스킹 처리 (예: `user@example.com` → `u***@e***.com`)

4. **컨텍스트 유지**: 요청 처리 과정에서 동일한 요청 ID 사용
   ```javascript
   logger.request(req).info('작업 시작');
   // 작업 처리...
   logger.request(req).info('작업 완료');
   ```

5. **에러 처리**: 에러 객체를 직접 로깅하여 스택 트레이스 보존
   ```javascript
   try {
     // 코드...
   } catch (error) {
     logger.error(error);
     res.status(500).send('Server error');
   }
   ```

## 환경 변수 설정

로깅 동작은 다음 환경 변수로 제어할 수 있습니다:

- `LOG_LEVEL`: 로그 레벨 지정 (기본값: 환경에 따라 자동 설정)
- `NODE_ENV`: 환경에 따른 로깅 동작 제어
  - `production`: info 이상 로깅
  - `development`: 모든 레벨 로깅
  - `test`: warn 이상 로깅