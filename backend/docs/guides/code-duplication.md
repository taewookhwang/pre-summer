# 코드 중복 제거 가이드

## 개요

코드 중복은 유지보수성을 저하시키고 버그의 원인이 될 수 있습니다. 이 가이드는 백엔드 코드에서 발견되는 일반적인 중복 패턴과 이를 해결하는 방법을 설명합니다.

## 일반적인 중복 패턴

백엔드 코드에서 자주 발견되는 중복 패턴은 다음과 같습니다:

1. **인증 및 권한 검사 로직**
   - JWT 토큰 검증
   - 사용자 역할 검사

2. **오류 처리 및 응답 형식**
   - 에러 응답 포맷팅
   - 오류 로깅 및 처리

3. **공통 미들웨어**
   - 요청 로깅
   - 응답 포맷팅
   - 입력 유효성 검사

4. **데이터 변환 로직**
   - camelCase ↔ snake_case 변환 (API 응답)
   - 날짜 및 시간 포맷팅

5. **유틸리티 함수**
   - 문자열, 숫자, 날짜 처리
   - 객체 조작

## 해결 방안

### 1. 공유 모듈 사용

Shared 디렉토리에 공통 모듈을 만들어 모든 서비스에서 활용합니다.

```javascript
// Shared/middleware/authMiddleware.js에서 정의
const { authenticateUser } = require('../../../Shared/middleware/authMiddleware');

// 각 서비스에서 사용
app.use(authenticateUser);
```

### 2. 표준 패턴 라이브러리 구현

자주 사용되는 패턴을 위한 표준 라이브러리를 구현합니다.

```javascript
// Shared/utils/response.js에서 정의
const { success, error } = require('../../../Shared/utils/response');

// 컨트롤러에서 사용
const controller = {
  getUsers: async (req, res) => {
    try {
      const users = await userService.getUsers();
      return response.send(res, response.success(users));
    } catch (err) {
      return response.send(res, response.error(err.message, err.statusCode));
    }
  }
};
```

### 3. 미들웨어 함수 추출

공통 미들웨어 함수를 추출하여 중복을 방지합니다.

```javascript
// Shared/middleware/errorMiddleware.js에서 정의
const { errorHandler, notFoundHandler } = require('../../../Shared/middleware/errorMiddleware');

// 각 서비스에서 사용
app.use(errorHandler);
app.use(notFoundHandler);
```

### 4. 고차 함수 사용

반복되는 로직을 캡슐화하는 고차 함수를 사용합니다.

```javascript
// 비동기 핸들러 래퍼
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// 컨트롤러에서 사용
router.get('/users', asyncHandler(controller.getUsers));
```

### 5. 믹스인 및 확장 패턴

공통 기능을 여러 클래스에 적용하려면 믹스인 패턴을 사용합니다.

```javascript
// 기본 컨트롤러 클래스
class BaseController {
  handleError(res, error) {
    // 공통 오류 처리 로직
  }
  
  sendSuccess(res, data) {
    // 공통 성공 응답 로직
  }
}

// 특정 컨트롤러에서 확장
class UserController extends BaseController {
  async getUsers(req, res) {
    try {
      const users = await this.userService.getUsers();
      this.sendSuccess(res, users);
    } catch (error) {
      this.handleError(res, error);
    }
  }
}
```

## 리팩토링 전략

### 1. 점진적 접근

모든 중복을 한 번에 제거하려고 하지 말고, 점진적으로 리팩토링하세요.

1. 중복 코드 식별
2. 가장 많이 중복된 부분부터 시작
3. 테스트 추가 (가능한 경우)
4. 리팩토링 수행
5. 테스트 검증 (가능한 경우)

### 2. 마이크로서비스별 접근

각 마이크로서비스를 순차적으로 리팩토링합니다.

1. 인증 및 권한 관련 코드
2. 오류 처리 코드
3. 응답 포맷팅 코드
4. 유틸리티 함수

### 3. 모니터링 및 검증

리팩토링 후 코드의 정상 작동을 확인하세요.

1. 코드 리뷰 진행
2. 자동화된 테스트 실행
3. 점진적 배포 및 모니터링

## 공통 코드 모듈

다음은 중복 방지를 위해 구현된 주요 공통 모듈입니다:

### 1. 미들웨어 모듈

- `Shared/middleware/authMiddleware.js`: 인증 관련 미들웨어
- `Shared/middleware/errorMiddleware.js`: 오류 처리 미들웨어
- `Shared/middleware/requestLoggerMiddleware.js`: 요청 로깅 미들웨어

### 2. 유틸리티 모듈

- `Shared/utils/response.js`: 응답 포맷팅 유틸리티
- `Shared/utils/index.js`: 일반 유틸리티 함수 모음

### 3. 오류 모듈

- `Shared/errors/index.js`: 표준 오류 클래스

## 적용 모범 사례

### 1. 공통 미들웨어 등록

모든 서비스에서 동일한 방식으로 미들웨어를 등록합니다.

```javascript
const express = require('express');
const { applyDefaultMiddleware, applyErrorHandlers } = require('../../../Shared/middleware');

const app = express();

// 기본 미들웨어 적용
applyDefaultMiddleware(app);

// 라우트 설정
app.use('/api', routes);

// 오류 처리 미들웨어 적용 (항상 마지막에)
applyErrorHandlers(app);
```

### 2. 표준 응답 유틸리티 사용

모든 컨트롤러에서 표준 응답 형식을 사용합니다.

```javascript
const { response } = require('../../../Shared/utils');

const controller = {
  // 성공 응답
  getUserById: async (req, res) => {
    try {
      const user = await userService.getUserById(req.params.id);
      if (!user) {
        return response.send(res, response.error('User not found', 404));
      }
      return response.send(res, response.success(user));
    } catch (err) {
      return response.send(res, response.error(err.message, 500));
    }
  },
  
  // 페이지네이션 응답
  getUsers: async (req, res) => {
    try {
      const { page = 1, limit = 20 } = req.query;
      const { users, total } = await userService.getUsers(page, limit);
      return response.send(res, response.paginated(users, total, page, limit));
    } catch (err) {
      return response.send(res, response.error(err.message, 500));
    }
  }
};
```

### 3. 공통 오류 클래스 사용

표준화된 오류 클래스를 사용하여 일관된 오류 처리를 구현합니다.

```javascript
const { BadRequestError, NotFoundError } = require('../../../Shared/errors');

const service = {
  getUserById: async (id) => {
    const user = await User.findByPk(id);
    if (!user) {
      throw new NotFoundError(`User with ID ${id} not found`);
    }
    return user;
  },
  
  createUser: async (userData) => {
    if (!userData.email) {
      throw new BadRequestError('Email is required');
    }
    // 나머지 로직
  }
};
```

## 결론

코드 중복을 제거하면 다음과 같은 이점이 있습니다:

1. **유지보수성 향상**: 변경사항을 한 곳에서만 수정하면 됩니다.
2. **일관성 확보**: 모든 서비스가 동일한 패턴을 사용합니다.
3. **버그 감소**: "한 번 수정, 여러 곳에서 해결" 효과를 얻습니다.
4. **개발 속도 향상**: 공통 모듈을 재사용하여 빠르게 개발할 수 있습니다.

코드 중복을 제거하는 것은 단기적으로는 추가 작업이 필요하지만, 장기적으로는 높은 품질의 코드베이스를 유지하는 데 큰 도움이 됩니다.