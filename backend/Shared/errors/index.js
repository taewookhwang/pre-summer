/**
 * @fileoverview 표준화된 애플리케이션 오류 클래스
 * 
 * 모든 마이크로서비스에서 일관된 오류 처리를 위한 표준 오류 클래스를 제공합니다.
 * 각 오류는 HTTP 상태 코드와 관련이 있으며, 클라이언트에 적절한 응답을 제공하는 데 사용됩니다.
 * 
 * @module Shared/errors
 */

/**
 * 기본 애플리케이션 오류 클래스
 * 
 * 모든 사용자 정의 오류의 기본 클래스입니다.
 * 
 * @class
 * @extends Error
 */
class AppError extends Error {
  /**
   * AppError 생성자
   * 
   * @param {string} message - 오류 메시지
   * @param {number} statusCode - HTTP 상태 코드
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message, statusCode, data = {}) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.data = data;
    this.isOperational = true; // 운영 오류 표시 (예측 가능한 오류)
    
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * 잘못된 요청 오류 (400)
 * 
 * 클라이언트 요청이 유효하지 않을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class BadRequestError extends AppError {
  /**
   * BadRequestError 생성자
   * 
   * @param {string} [message='Bad Request'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'Bad Request', data = {}) {
    super(message, 400, data);
  }
}

/**
 * 인증 오류 (401)
 * 
 * 인증이 필요하지만 제공되지 않았거나 유효하지 않을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class UnauthorizedError extends AppError {
  /**
   * UnauthorizedError 생성자
   * 
   * @param {string} [message='Unauthorized'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'Unauthorized', data = {}) {
    super(message, 401, data);
  }
}

/**
 * 접근 권한 오류 (403)
 * 
 * 인증은 되었지만 해당 리소스에 접근 권한이 없을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class ForbiddenError extends AppError {
  /**
   * ForbiddenError 생성자
   * 
   * @param {string} [message='Forbidden'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'Forbidden', data = {}) {
    super(message, 403, data);
  }
}

/**
 * 리소스 없음 오류 (404)
 * 
 * 요청한 리소스를 찾을 수 없을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class NotFoundError extends AppError {
  /**
   * NotFoundError 생성자
   * 
   * @param {string} [message='Resource Not Found'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'Resource Not Found', data = {}) {
    super(message, 404, data);
  }
}

/**
 * 유효성 검증 오류 (422)
 * 
 * 요청 데이터가 유효성 검증에 실패했을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class ValidationError extends AppError {
  /**
   * ValidationError 생성자
   * 
   * @param {string} [message='Validation Error'] - 오류 메시지
   * @param {Object} [data] - 유효성 검증 오류 세부 정보
   */
  constructor(message = 'Validation Error', data = {}) {
    super(message, 422, data);
  }
}

/**
 * 서비스 제한 초과 오류 (429)
 * 
 * 클라이언트가 너무 많은 요청을 보냈을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class TooManyRequestsError extends AppError {
  /**
   * TooManyRequestsError 생성자
   * 
   * @param {string} [message='Too Many Requests'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터 (다음 요청 가능 시간 등)
   */
  constructor(message = 'Too Many Requests', data = {}) {
    super(message, 429, data);
  }
}

/**
 * 서버 내부 오류 (500)
 * 
 * 서버 내부 오류가 발생했을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class InternalServerError extends AppError {
  /**
   * InternalServerError 생성자
   * 
   * @param {string} [message='Internal Server Error'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'Internal Server Error', data = {}) {
    super(message, 500, data);
  }
}

/**
 * 서비스 사용 불가 오류 (503)
 * 
 * 서비스가 일시적으로 사용 불가능할 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class ServiceUnavailableError extends AppError {
  /**
   * ServiceUnavailableError 생성자
   * 
   * @param {string} [message='Service Unavailable'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'Service Unavailable', data = {}) {
    super(message, 503, data);
  }
}

/**
 * 데이터베이스 오류 (500)
 * 
 * 데이터베이스 작업 중 오류가 발생했을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class DatabaseError extends AppError {
  /**
   * DatabaseError 생성자
   * 
   * @param {string} [message='Database Error'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'Database Error', data = {}) {
    super(message, 500, data);
  }
}

/**
 * 외부 서비스 오류 (502)
 * 
 * 외부 서비스 호출 중 오류가 발생했을 때 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class ExternalServiceError extends AppError {
  /**
   * ExternalServiceError 생성자
   * 
   * @param {string} [message='External Service Error'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'External Service Error', data = {}) {
    super(message, 502, data);
  }
}

/**
 * 비즈니스 로직 오류 (400)
 * 
 * 비즈니스 규칙 위반 시 사용합니다.
 * 
 * @class
 * @extends AppError
 */
class BusinessError extends AppError {
  /**
   * BusinessError 생성자
   * 
   * @param {string} [message='Business Rule Violation'] - 오류 메시지
   * @param {Object} [data] - 추가 오류 데이터
   */
  constructor(message = 'Business Rule Violation', data = {}) {
    super(message, 400, data);
  }
}

module.exports = {
  AppError,
  BadRequestError,
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  ValidationError,
  TooManyRequestsError,
  InternalServerError,
  ServiceUnavailableError,
  DatabaseError,
  ExternalServiceError,
  BusinessError,
};