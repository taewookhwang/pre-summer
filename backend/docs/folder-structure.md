# 폴더 구조 가이드

## 개요

이 문서는 백엔드 프로젝트의 폴더 및 파일 구조에 대한 표준과 모범 사례를 설명합니다. 이 가이드를 따르면 코드베이스를 보다 일관되고 유지보수하기 쉽게 만들 수 있습니다.

## 기본 폴더 구조

프로젝트는 다음과 같은 주요 폴더 구조를 가집니다:

```
/
├── Gateway/             # API 게이트웨이
├── Services/            # 마이크로서비스 모음
├── Shared/              # 공유 모듈 및 유틸리티
├── Infrastructure/      # 인프라 설정 및 환경 변수
├── docs/                # 프로젝트 문서
└── tests/               # 통합 테스트
```

## 마이크로서비스 구조

각 마이크로서비스는 기능별로 분리되어 있으며, 다음과 같은 내부 구조를 가집니다:

```
Services/{ServiceName}/
├── src/
│   ├── controllers/     # 요청 처리 컨트롤러
│   ├── services/        # 비즈니스 로직
│   ├── models/          # 데이터 모델
│   ├── middleware/      # 미들웨어
│   ├── routes/          # 라우트 정의
│   ├── utils/           # 서비스별 유틸리티
│   └── index.js         # 서비스 진입점
├── tests/               # 서비스별 단위 테스트
└── package.json         # 서비스별 의존성 (선택 사항)
```

## API 게이트웨이 구조

API 게이트웨이는 모든 외부 요청을 적절한 마이크로서비스로 라우팅합니다:

```
Gateway/
├── src/
│   ├── middleware/      # 게이트웨이 미들웨어 (인증, 로깅 등)
│   ├── routes/          # 서비스 라우팅 정의
│   ├── utils/           # 게이트웨이 유틸리티
│   └── index.js         # 게이트웨이 진입점
└── tests/               # 게이트웨이 테스트
```

## 공유 모듈 구조

여러 서비스에서 공통으로 사용하는 기능을 포함합니다:

```
Shared/
├── cache/               # 캐싱 유틸리티
├── config/              # 설정 관리
├── database/            # DB 연결 및 공통 모델
├── logger/              # 로깅 유틸리티
├── validation/          # 공통 유효성 검증
├── utils/               # 기타 공통 유틸리티
└── errors/              # 표준화된 오류 클래스
```

## 인프라 구조

시스템 전체 설정과 인프라 관련 파일을 포함합니다:

```
Infrastructure/
├── .env.development     # 개발 환경 설정
├── .env.test            # 테스트 환경 설정
├── .env.production      # 운영 환경 설정
├── .env.example         # 환경 변수 예제
├── docker-compose.yml   # Docker 구성
└── nginx.conf           # Nginx 설정 (필요한 경우)
```

## 문서 구조

프로젝트 문서는 다음과 같이 구성됩니다:

```
docs/
├── api/                 # API 문서 (자동 생성)
├── guides/              # 개발 가이드
├── architecture/        # 아키텍처 문서
└── README.md            # 주요 문서 인덱스
```

## 파일 명명 규칙

### 일반 규칙

- 모든 JavaScript 파일은 `.js` 확장자를 사용합니다.
- 모든 파일 및 폴더 이름은 소문자 `camelCase` 또는 `kebab-case`를 사용합니다.
- 단일 책임 원칙을 따르도록 파일을 구성합니다.

### 컴포넌트별 규칙

1. **컨트롤러**:
   - 파일명: `{resource}Controller.js` (예: `userController.js`)
   - 클래스명: `{Resource}Controller` (예: `UserController`)

2. **서비스**:
   - 파일명: `{resource}Service.js` (예: `userService.js`)
   - 클래스명: `{Resource}Service` (예: `UserService`)

3. **모델**:
   - 파일명: 단수형 `{Resource}.js` (예: `User.js`)
   - 클래스명: 단수형 `{Resource}` (예: `User`)

4. **라우트**:
   - 파일명: `{resource}Routes.js` (예: `userRoutes.js`)

5. **미들웨어**:
   - 파일명: `{purpose}Middleware.js` (예: `authMiddleware.js`)

6. **유틸리티**:
   - 파일명: 기능 설명 (예: `formatter.js`, `validator.js`)

## 모듈 가져오기 및 내보내기 패턴

### 가져오기 순서

임포트 구문은 다음 순서로 정렬합니다:

1. 외부 라이브러리 및 모듈
2. 프로젝트 내 다른 모듈 (상대 경로)
3. 로컬 모듈 및 파일

예시:
```javascript
// 1. 외부 라이브러리
const express = require('express');
const jwt = require('jsonwebtoken');

// 2. 프로젝트 내 공유 모듈
const logger = require('../../../../Shared/logger');
const config = require('../../../../Shared/config');

// 3. 로컬 모듈 및 파일
const User = require('../models/User');
const authMiddleware = require('../middleware/authMiddleware');
```

### 내보내기 패턴

다음 내보내기 패턴을 일관되게 사용합니다:

1. **클래스 내보내기**:
   ```javascript
   class UserService {
     // 클래스 구현
   }
   
   module.exports = new UserService();
   ```

2. **함수 모음 내보내기**:
   ```javascript
   const validators = {
     validateEmail: (email) => { /* 구현 */ },
     validatePassword: (password) => { /* 구현 */ },
   };
   
   module.exports = validators;
   ```

3. **기본 객체 내보내기**:
   ```javascript
   const config = {
     // 설정 값
   };
   
   module.exports = config;
   ```

## 추가 구성 디렉토리 (필요한 경우)

필요에 따라 다음과 같은 추가 디렉토리를 구성할 수 있습니다:

1. **스크립트 디렉토리**:
   ```
   scripts/              # 유틸리티 스크립트
   ├── db-seed.js        # 초기 데이터 시드 스크립트
   ├── migration.js      # 마이그레이션 스크립트
   └── deploy.js         # 배포 스크립트
   ```

2. **타입 정의 디렉토리** (TypeScript 사용 시):
   ```
   types/                # 타입 정의
   ├── models/           # 모델 타입
   ├── api/              # API 요청/응답 타입
   └── index.d.ts        # 글로벌 타입 정의
   ```

## 모범 사례

1. **상대 경로 간소화**: `Shared` 모듈에 대한 경로가 너무 깊은 경우, 서비스 내에서 별칭 사용 고려
2. **단일 책임 원칙**: 각 파일과 모듈은 한 가지 역할만 수행하도록 설계
3. **일관된 디렉토리 구조**: 모든 서비스는 동일한 내부 구조 유지
4. **명시적 의존성**: 필요한 모든 의존성을 명시적으로 가져오기
5. **적절한 캡슐화**: 외부에 노출할 인터페이스만 내보내기

## 파일 헤더 주석 템플릿

모든 주요 파일에는 다음과 같은 헤더 주석을 포함하는 것이 좋습니다:

```javascript
/**
 * @fileoverview 파일 목적에 대한 설명
 * 
 * @module path/to/module
 * @requires dependency1
 * @requires dependency2
 */
```

## 마이그레이션 계획

기존 프로젝트 구조에서 이 표준화된 구조로 점진적으로 마이그레이션하기 위한 권장 접근 방식:

1. 공유 모듈부터 시작하여 표준화
2. 서비스별로 구조 업데이트
3. 테스트 추가 및 업데이트
4. 문서화 개선