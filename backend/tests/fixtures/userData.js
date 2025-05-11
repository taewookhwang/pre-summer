/**
 * @fileoverview 테스트용 사용자 데이터 모음
 * 
 * 테스트에서 사용할 수 있는 다양한 사용자 관련 테스트 데이터를 제공합니다.
 * 
 * @module tests/fixtures/userData
 */

/**
 * 유효한 소비자 사용자 데이터
 */
const validConsumer = {
  email: 'consumer@example.com',
  password: 'Password123!',
  role: 'consumer',
  name: '홍길동',
  phone: '010-1234-5678',
  address: {
    street: '서울특별시 강남구 테헤란로 123',
    detail: '타워 1234호',
    postalCode: '06234',
  },
};

/**
 * 유효한 기술자 사용자 데이터
 */
const validTechnician = {
  email: 'technician@example.com',
  password: 'Password123!',
  role: 'technician',
  name: '김기술',
  phone: '010-9876-5432',
  address: {
    street: '서울특별시 강남구 테헤란로 456',
    detail: '타워 5678호',
    postalCode: '06234',
  },
  skills: ['청소', '정리', '세척'],
  experience: 3,
  introduction: '10년 경력의 전문 홈클리닝 기술자입니다.',
};

/**
 * 유효한 관리자 사용자 데이터
 */
const validAdmin = {
  email: 'admin@example.com',
  password: 'AdminPassword123!',
  role: 'admin',
  name: '관리자',
  phone: '010-1111-2222',
};

/**
 * 이메일이 유효하지 않은 사용자 데이터
 */
const invalidEmail = {
  email: 'invalid-email',
  password: 'Password123!',
  role: 'consumer',
  name: '이메일오류',
  phone: '010-1234-5678',
};

/**
 * 비밀번호가 유효하지 않은 사용자 데이터 (너무 짧음)
 */
const invalidPasswordShort = {
  email: 'test@example.com',
  password: 'Pass1!',
  role: 'consumer',
  name: '비번오류',
  phone: '010-1234-5678',
};

/**
 * 비밀번호가 유효하지 않은 사용자 데이터 (복잡성 부족)
 */
const invalidPasswordComplexity = {
  email: 'test@example.com',
  password: 'password',
  role: 'consumer',
  name: '비번오류',
  phone: '010-1234-5678',
};

/**
 * 역할이 유효하지 않은 사용자 데이터
 */
const invalidRole = {
  email: 'test@example.com',
  password: 'Password123!',
  role: 'invalid-role',
  name: '역할오류',
  phone: '010-1234-5678',
};

/**
 * 전화번호가 유효하지 않은 사용자 데이터
 */
const invalidPhone = {
  email: 'test@example.com',
  password: 'Password123!',
  role: 'consumer',
  name: '전화오류',
  phone: '01012345678', // 하이픈 없음
};

/**
 * 필수 필드가 누락된 사용자 데이터
 */
const missingRequiredFields = {
  email: 'test@example.com',
  password: 'Password123!',
  // 역할 누락
  // 이름 누락
};

/**
 * 로그인 자격 증명
 */
const loginCredentials = {
  valid: {
    email: 'consumer@example.com',
    password: 'Password123!',
  },
  invalidEmail: {
    email: 'nonexistent@example.com',
    password: 'Password123!',
  },
  invalidPassword: {
    email: 'consumer@example.com',
    password: 'WrongPassword123!',
  },
};

/**
 * JWT 토큰 테스트 데이터
 */
const tokens = {
  // 테스트용 만료된 토큰
  expired: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiaWF0IjoxNTc1MTU0NTg3LCJleHAiOjE1NzUxNTQ1ODh9.XMKfLyS0-wkIj4Mak-mCH7FSHc-m2SyYXN9oZ-iJzg4',
  
  // 테스트용 유효하지 않은 토큰
  invalid: 'invalid-token',
  
  // 개발 환경용 테스트 토큰
  testConsumer: 'test_token_consumer_1',
  testTechnician: 'test_token_technician_1',
  testAdmin: 'test_token_admin_1',
};

/**
 * 테스트 사용자 ID 목록
 */
const userIds = {
  consumer: 1,
  technician: 2,
  admin: 3,
  nonexistent: 999,
};

module.exports = {
  validConsumer,
  validTechnician,
  validAdmin,
  invalidEmail,
  invalidPasswordShort,
  invalidPasswordComplexity,
  invalidRole,
  invalidPhone,
  missingRequiredFields,
  loginCredentials,
  tokens,
  userIds,
};