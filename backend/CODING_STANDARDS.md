# 코드 작성 표준 가이드

이 문서는 홈클리닝 백엔드 프로젝트의 코드 작성 표준과 스타일 가이드를 정의합니다.

## 일반 원칙

- **일관성**: 코드 전체에 걸쳐 일관된 스타일을 유지합니다.
- **가독성**: 코드는 명확하고 이해하기 쉽게 작성합니다.
- **모듈화**: 코드는 재사용 가능한 작은 모듈로 분리합니다.
- **문서화**: 코드의 목적과 기능을 명확히 문서화합니다.
- **테스트**: 모든 기능은 테스트 가능하도록 작성합니다.

## 코드 스타일

프로젝트는 ESLint와 Prettier를 사용하여 코드 스타일을 강제합니다.

### 설정 파일

- `.eslintrc.js`: ESLint 규칙 정의
- `.prettierrc.js`: Prettier 포맷팅 규칙 정의
- `.eslintignore`: ESLint 검사에서 제외할 파일 목록
- `.prettierignore`: Prettier 포맷팅에서 제외할 파일 목록

### 스크립트

코드 품질 관리를 위해 다음 스크립트를 사용합니다:

```bash
# 코드 스타일 문제 검사
npm run lint

# 코드 스타일 문제 자동 수정
npm run lint:fix

# 코드 포맷팅 적용
npm run format

# 코드 포맷팅 확인(수정 없음)
npm run format:check
```

### 주요 스타일 규칙

- **들여쓰기**: 2칸 스페이스
- **문자열**: 작은따옴표 사용 (`'string'`)
- **세미콜론**: 모든 문장 끝에 세미콜론 사용
- **한 줄 최대 길이**: 100자
- **후행 쉼표**: 여러 줄의 객체, 배열에서 사용
- **변수 선언**: `const` 사용 (재할당 필요시 `let`)
- **함수 선언**: 화살표 함수 사용 권장

## 파일 구조 표준

각 서비스는 다음과 같은 일관된 디렉토리 구조를 따라야 합니다:

```
ServiceName/
├── src/
│   ├── controllers/    # 컨트롤러 함수들 (요청 처리 로직)
│   ├── middleware/     # 미들웨어 (인증, 요청 검증 등)
│   ├── models/         # 데이터 모델 (DB 스키마)
│   ├── routes/         # 라우트 정의
│   ├── services/       # 비즈니스 로직
│   └── index.js        # 서비스 진입점
├── tests/              # 테스트 파일들
└── package.json        # 서비스별 의존성 정의
```

## 네이밍 규칙

- **파일명**:
  - 컨트롤러 및 서비스: camelCase + 역할 접미사 (예: `userController.js`, `authService.js`)
  - 모델: PascalCase, 단수형 (예: `User.js`, `Reservation.js`)
  - 인덱스 파일: `index.js`
- **변수명**:

  - 일반 변수: camelCase (예: `userId`, `reservationData`)
  - 상수: 대문자 스네이크 케이스 (예: `MAX_ATTEMPTS`, `DEFAULT_TIMEOUT`)
  - 불리언 변수: 'is', 'has', 'can' 등 접두사 사용 (예: `isActive`, `hasPermission`)

- **함수명**:

  - 일반 함수: camelCase, 동사로 시작 (예: `getUserById`, `createReservation`)
  - 이벤트 핸들러: 'handle' 접두사 사용 (예: `handleSubmit`, `handleClick`)
  - 프라미스 반환 함수: 비동기 동작 암시 (예: `fetchData`, `loadUser`)

- **클래스명**: PascalCase (예: `UserService`, `AuthController`)

## API 응답 형식 표준

모든 API 응답은 다음 구조를 따라야 합니다:

### 성공 응답

```json
{
  "success": true,
  "data": { ... },  // 또는 특정 리소스 이름 사용 (users, reservations 등)
  "message": "Optional success message"
}
```

### 오류 응답

```json
{
  "success": false,
  "error": {
    "message": "Human readable error message",
    "details": "Technical details or validation errors"
  }
}
```

## 문서화 표준

모든 함수와 클래스는 JSDoc 주석으로 문서화합니다:

```javascript
/**
 * 사용자 정보를 조회합니다.
 *
 * @param {string} userId - 조회할 사용자의 ID
 * @returns {Promise<Object>} 사용자 정보 객체
 * @throws {Error} 사용자를 찾을 수 없을 경우
 */
const getUser = async (userId) => {
  // 구현...
};
```

## 로깅 표준

로깅에는 공통 로거 모듈(`Shared/logger`)을 사용합니다:

```javascript
const logger = require('../../../Shared/logger');

// 기본 로깅
logger.debug('디버그 메시지');
logger.info('정보 메시지');
logger.warn('경고 메시지');
logger.error('에러 메시지', { additionalData: 'someData' });

// 요청 컨텍스트 로깅 (미들웨어 이후)
const requestLogger = logger.request(req);
requestLogger.info('요청 처리 중');
```

## 환경 변수 사용 표준

환경 변수에는 공통 설정 모듈(`Shared/config`)을 사용합니다:

```javascript
const config = require('../../../Shared/config');

// 환경 변수 사용
const port = config.server.auth.port;
const dbConfig = config.db;
const jwtSecret = config.jwt.secret;

// 필수 환경 변수 검증
config.validateRequired(['DB_HOST', 'DB_USERNAME', 'JWT_SECRET']);
```

## 테스트 표준

모든 비즈니스 로직은 단위 테스트를 작성해야 합니다:

- **이름 지정**: `{파일명}.test.js` 또는 `{파일명}.spec.js`
- **프레임워크**: Jest
- **목업**: 외부 의존성은 항상 목업하여 테스트
- **범위**: 최소한 모든 서비스 함수와 컨트롤러에 대한 테스트 작성
