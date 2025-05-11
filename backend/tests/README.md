# 테스트 가이드

이 디렉토리는 백엔드 시스템의 테스트를 포함합니다. 테스트는 단위 테스트, 통합 테스트, E2E 테스트의 세 가지 카테고리로 구성됩니다.

## 테스트 구조

```
tests/
├── unit/                # 단위 테스트
│   ├── services/        # 서비스 단위 테스트
│   ├── controllers/     # 컨트롤러 단위 테스트
│   ├── models/          # 모델 단위 테스트
│   └── utils/           # 유틸리티 단위 테스트
├── integration/         # 통합 테스트
│   ├── api/             # API 통합 테스트
│   ├── database/        # 데이터베이스 통합 테스트
│   └── services/        # 서비스 간 통합 테스트
├── e2e/                 # 엔드-투-엔드 테스트
│   ├── scenarios/       # 비즈니스 시나리오 테스트
│   └── flows/           # 사용자 플로우 테스트
├── fixtures/            # 테스트 데이터 및 픽스처
├── helpers/             # 테스트 헬퍼 함수
└── config/              # 테스트 설정
```

## 테스트 실행 방법

테스트는 npm 스크립트를 통해 실행할 수 있습니다:

```bash
# 모든 테스트 실행
npm test

# 단위 테스트만 실행
npm run test:unit

# 통합 테스트만 실행
npm run test:integration

# E2E 테스트만 실행
npm run test:e2e

# 특정 파일 테스트 실행
npm test -- tests/unit/services/authService.test.js
```

## 테스트 작성 가이드

### 단위 테스트

단위 테스트는 코드의 작은 단위(함수, 메서드, 클래스)가 예상대로 작동하는지 확인합니다.

```javascript
const { expect } = require('chai');
const sinon = require('sinon');
const authService = require('../../../Services/AuthService/src/services/authService');
const User = require('../../../Services/AuthService/src/models/User');

describe('AuthService', () => {
  describe('login', () => {
    it('should return user and tokens when credentials are valid', async () => {
      // 테스트 코드
    });

    it('should throw error when user not found', async () => {
      // 테스트 코드
    });
  });
});
```

### 통합 테스트

통합 테스트는 여러 컴포넌트가 함께 작동하는 방식을 테스트합니다.

```javascript
const request = require('supertest');
const { expect } = require('chai');
const app = require('../../../Gateway/src/index');
const db = require('../../../Shared/database');

describe('Authentication API', () => {
  before(async () => {
    // 데이터베이스 설정
  });

  after(async () => {
    // 정리
  });

  it('should register a new user', async () => {
    // 테스트 코드
  });
});
```

### E2E 테스트

E2E 테스트는 실제 사용자 시나리오를 시뮬레이션하여 전체 시스템을 테스트합니다.

```javascript
const { expect } = require('chai');
const request = require('supertest');
const app = require('../../../Gateway/src/index');

describe('User Reservation Flow', () => {
  let token;
  let userId;

  before(async () => {
    // 사용자 로그인 및 설정
  });

  it('should browse service categories', async () => {
    // 테스트 코드
  });

  it('should create a reservation', async () => {
    // 테스트 코드
  });
});
```

## 테스트 모범 사례

1. **독립성**: 각 테스트는 독립적이어야 하며 다른 테스트에 의존하지 않아야 합니다.
2. **고립**: 단위 테스트에서는 외부 의존성을 모킹하거나 스텁하여 테스트 중인 코드를 고립시킵니다.
3. **명확성**: 테스트 이름과 구조는 명확하고 이해하기 쉬워야 합니다.
4. **완전성**: 성공 케이스와 실패 케이스를 모두 테스트합니다.
5. **속도**: 테스트는 가능한 빠르게 실행되어야 합니다.

## 모킹 및 스텁

외부 의존성을 모킹하기 위해 Sinon.js를 사용합니다:

```javascript
const sinon = require('sinon');
const User = require('../../../Services/AuthService/src/models/User');

// 데이터베이스 호출 모킹
const userFindOneStub = sinon.stub(User, 'findOne');
userFindOneStub.resolves({ id: 1, email: 'test@example.com' });

// 테스트 후 복원
userFindOneStub.restore();
```

## 테스트 데이터

테스트 데이터는 `fixtures` 디렉토리에 저장하고 가져와서 사용합니다:

```javascript
const userData = require('../../fixtures/userData');

// 테스트에서 사용
const result = await authService.registerUser(userData.validUser);
```