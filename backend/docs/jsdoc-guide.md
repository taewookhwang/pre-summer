# JSDoc 주석 스타일 가이드

## 개요

이 문서는 프로젝트 전반에 걸쳐 일관된 코드 문서화를 위한 JSDoc 스타일 가이드입니다. 
모든 새로운 코드와 기존 코드의 수정은 이 가이드를 준수해야 합니다.

## 기본 원칙

1. **모든 공개 API에 문서화**: 모든 함수, 클래스, 메서드는 JSDoc 주석을 포함해야 합니다.
2. **명확성**: 간결하고 명확한 설명으로 코드의 목적과 사용법을 설명합니다.
3. **타입 정보**: 매개변수와 반환 값의 타입을 항상 명시합니다.
4. **예제 제공**: 복잡한 기능의 경우 사용 예제를 제공합니다.

## 주석 형식

### 파일 상단 주석

각 파일의 상단에는 파일의 목적을 설명하는 주석 블록을 포함해야 합니다:

```javascript
/**
 * 사용자 인증 관련 기능을 제공하는 모듈
 * 
 * 이 모듈은 로그인, 회원가입, 토큰 갱신 등의 인증 관련 
 * 기능들을 포함합니다.
 * 
 * @module auth/authService
 */
```

### 함수 및 메서드 주석

모든 함수와 메서드에는 다음 형식의 JSDoc 주석을 사용합니다:

```javascript
/**
 * 사용자 로그인 처리 함수
 * 
 * @param {Object} credentials - 사용자 인증 정보
 * @param {string} credentials.email - 사용자 이메일
 * @param {string} credentials.password - 사용자 비밀번호
 * @param {Object} [options] - 추가 옵션 (선택적)
 * @param {boolean} [options.rememberMe=false] - 자동 로그인 여부
 * @returns {Promise<Object>} 인증 토큰 및 사용자 정보
 * @throws {AuthError} 인증 실패 시 오류 발생
 */
async function login(credentials, options = {}) {
  // 함수 구현
}
```

### 클래스 주석

클래스 정의에는 다음 형식의 주석을 사용합니다:

```javascript
/**
 * 사용자 정보 관리 클래스
 * 
 * @class
 */
class UserManager {
  /**
   * UserManager 생성자
   * 
   * @param {Object} options - 초기화 옵션
   * @param {UserRepository} options.repository - 사용자 저장소 인스턴스
   */
  constructor(options) {
    // 생성자 구현
  }
  
  /**
   * 클래스 메서드 설명
   * 
   * @param {string} userId - 사용자 ID
   * @returns {Promise<User>} 사용자 객체
   * @throws {NotFoundError} 사용자를 찾을 수 없는 경우
   */
  async getUserById(userId) {
    // 메서드 구현
  }
}
```

### 상수 및 변수 주석

중요한 상수 및 변수에는 간단한 설명을 추가합니다:

```javascript
/** 비밀번호 해시에 사용되는 솔트 라운드 수 */
const SALT_ROUNDS = 10;

/** 기본 페이지 크기 */
const DEFAULT_PAGE_SIZE = 20;
```

## 타입 표기법

### 기본 타입

- `{string}`: 문자열
- `{number}`: 숫자
- `{boolean}`: 불리언
- `{Object}`: 객체
- `{Array}`: 배열
- `{Date}`: 날짜
- `{RegExp}`: 정규식
- `{Function}`: 함수
- `{*}`: 모든 타입

### 복합 타입

- `{(string|number)}`: 문자열 또는 숫자
- `{Array<string>}` 또는 `{string[]}`: 문자열 배열
- `{Object<string, number>}`: 문자열 키와 숫자 값을 가진 객체
- `{Promise<User>}`: User 객체로 해결되는 Promise

### 선택적 매개변수와 기본값

- `{string} [name]`: 선택적 문자열 매개변수
- `{number} [count=10]`: 기본값이 10인 선택적 숫자 매개변수

## 주요 JSDoc 태그

### 필수 태그

- `@param`: 함수 매개변수 설명
- `@returns`: 반환 값 설명
- `@throws`: 발생 가능한 예외 설명
- `@class`: 클래스 정의
- `@module`: 모듈 정의

### 자주 사용하는 태그

- `@async`: 비동기 함수 표시
- `@example`: 사용 예제 제공
- `@deprecated`: 더 이상 사용되지 않는 기능 표시
- `@see`: 관련 정보에 대한 참조
- `@todo`: 해야 할 작업 표시
- `@private`: 비공개 멤버 표시
- `@ignore`: 문서 생성 시 제외할 멤버 표시

## 예제

### 비동기 함수 예제

```javascript
/**
 * 사용자 목록을 가져옵니다.
 * 
 * @async
 * @param {Object} options - 조회 옵션
 * @param {number} [options.page=1] - 페이지 번호
 * @param {number} [options.limit=20] - 페이지당 항목 수
 * @param {string} [options.sortBy='createdAt'] - 정렬 기준 필드
 * @param {string} [options.sortOrder='desc'] - 정렬 방향 ('asc' 또는 'desc')
 * @returns {Promise<Object>} 사용자 목록 및 페이지네이션 정보
 * @throws {DatabaseError} 데이터베이스 조회 오류 발생 시
 * 
 * @example
 * // 기본 사용법
 * const result = await getUserList();
 * 
 * // 페이지네이션과 정렬 지정
 * const result = await getUserList({ 
 *   page: 2, 
 *   limit: 10, 
 *   sortBy: 'name', 
 *   sortOrder: 'asc' 
 * });
 */
async function getUserList(options = {}) {
  // 함수 구현
}
```

### 복잡한 객체 매개변수

```javascript
/**
 * 예약을 생성합니다.
 * 
 * @param {Object} reservationData - 예약 데이터
 * @param {string} reservationData.userId - 사용자 ID
 * @param {string} reservationData.serviceId - 서비스 ID
 * @param {Date} reservationData.scheduledTime - 예약 날짜/시간
 * @param {Object} reservationData.address - 서비스 제공 주소
 * @param {string} reservationData.address.street - 도로명 주소
 * @param {string} reservationData.address.detail - 상세 주소
 * @param {string} reservationData.address.postalCode - 우편번호
 * @param {Object} [reservationData.address.coordinates] - 위치 좌표
 * @param {number} [reservationData.address.coordinates.latitude] - 위도
 * @param {number} [reservationData.address.coordinates.longitude] - 경도
 * @param {string} [reservationData.specialInstructions] - 특별 요청사항
 * @param {Array<Object>} [reservationData.serviceOptions] - 서비스 옵션 목록
 * @param {string} reservationData.serviceOptions[].option_id - 옵션 ID
 * @param {number} [reservationData.serviceOptions[].quantity=1] - 옵션 수량
 * @returns {Promise<Object>} 생성된 예약 정보
 * @throws {ValidationError} 유효성 검사 실패 시
 * @throws {ServiceError} 서비스 처리 오류 발생 시
 */
async function createReservation(reservationData) {
  // 함수 구현
}
```

### 콜백 함수

```javascript
/**
 * 비동기 작업의 진행 상태를 모니터링합니다.
 * 
 * @param {string} jobId - 작업 ID
 * @param {Object} [options] - 모니터링 옵션
 * @param {number} [options.interval=1000] - 상태 확인 간격 (밀리초)
 * @param {number} [options.timeout=30000] - 최대 대기 시간 (밀리초)
 * @param {Function} [progressCallback] - 진행 상태 콜백 함수
 * @param {number} progressCallback.progress - 진행률 (0-100)
 * @param {string} progressCallback.status - 상태 메시지
 * @returns {Promise<Object>} 작업 결과
 */
async function monitorJobProgress(jobId, options = {}, progressCallback) {
  // 함수 구현
}
```

## 문서 생성

JSDoc 주석은 [JSDoc](https://jsdoc.app/) 도구를 사용하여 HTML 문서로 변환할 수 있습니다:

```bash
# JSDoc 설치
npm install -g jsdoc

# 문서 생성
jsdoc -c jsdoc.config.json -r ./src -d ./docs/api
```

## 사용할 수 있는 JSDoc 플러그인

- **ESLint JSDoc 플러그인**: ESLint에 JSDoc 규칙을 추가합니다.
- **VS Code용 Document This**: VS Code에서 JSDoc 주석을 자동으로 생성합니다.
- **Better Comments**: 주석을 시각적으로 구분하여 표시합니다.

## 결론

이 가이드를 준수하여 일관되고 유지보수하기 쉬운 코드베이스를 만들어 나갈 수 있습니다. 
코드 문서화는 코드 품질의 중요한 부분이며, 팀 협업과 코드 이해도를 높이는 데 큰 도움이 됩니다.