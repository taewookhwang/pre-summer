/**
 * @fileoverview 오류 처리 공통 미들웨어
 * 
 * 모든 마이크로서비스에서 공통으로 사용하는 오류 처리 미들웨어를 제공합니다.
 * 일관된 오류 응답 형식과 오류 로깅을 처리합니다.
 * 
 * @module Shared/middleware/errorMiddleware
 */

const logger = require('../logger');
const { AppError } = require('../errors');

/**
 * 에러 처리 미들웨어
 * 발생한 오류를 잡아서 적절한 형식으로 응답합니다.
 * 
 * @param {Error} err - 오류 객체
 * @param {Object} req - Express 요청 객체
 * @param {Object} res - Express 응답 객체
 * @param {Function} next - Express 다음 미들웨어 함수
 * @returns {void}
 */
exports.errorHandler = (err, req, res, next) => {
  // 요청 ID가 있으면 로그에 포함
  const logContext = req.requestId ? { requestId: req.requestId } : {};
  
  // 요청 경로 정보 추가
  const reqInfo = {
    method: req.method,
    url: req.originalUrl || req.url,
    ip: req.ip,
  };
  
  // AppError 인스턴스인 경우
  if (err instanceof AppError) {
    logger.error(`[${err.statusCode}] ${err.name}: ${err.message}`, { 
      ...logContext,
      ...reqInfo,
      data: err.data,
      stack: err.stack 
    });
    
    return res.status(err.statusCode).json({
      success: false,
      error: {
        message: err.message,
        details: err.data,
        code: err.name,
      },
    });
  }
  
  // 유효성 검증 오류 (express-validator 사용 시)
  if (err.array && typeof err.array === 'function') {
    const validationErrors = err.array();
    logger.error(`Validation Error: ${JSON.stringify(validationErrors)}`, { 
      ...logContext,
      ...reqInfo
    });
    
    return res.status(422).json({
      success: false,
      error: {
        message: 'Validation failed',
        details: validationErrors,
        code: 'ValidationError',
      },
    });
  }
  
  // JWT 관련 오류
  if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
    logger.error(`JWT Error: ${err.message}`, { 
      ...logContext,
      ...reqInfo,
      stack: err.stack 
    });
    
    return res.status(401).json({
      success: false,
      error: {
        message: err.name === 'TokenExpiredError' ? 'Token has expired' : 'Invalid token',
        details: err.message,
        code: err.name,
      },
    });
  }
  
  // Sequelize 데이터베이스 오류
  if (err.name === 'SequelizeValidationError' || err.name === 'SequelizeUniqueConstraintError') {
    const validationErrors = err.errors.map(e => ({
      field: e.path,
      message: e.message,
      value: e.value,
    }));
    
    logger.error(`Database Validation Error: ${err.message}`, { 
      ...logContext,
      errors: validationErrors,
      stack: err.stack 
    });
    
    return res.status(422).json({
      success: false,
      error: {
        message: 'Database validation failed',
        details: validationErrors,
        code: err.name,
      },
    });
  }
  
  // 기타 Sequelize 오류
  if (err.name && err.name.startsWith('Sequelize')) {
    logger.error(`Database Error: ${err.message}`, { 
      ...logContext,
      ...reqInfo,
      stack: err.stack 
    });
    
    return res.status(500).json({
      success: false,
      error: {
        message: 'Database operation failed',
        details: process.env.NODE_ENV === 'development' ? err.message : 'Internal database error',
        code: err.name,
      },
    });
  }
  
  // 그 외 모든 오류
  const statusCode = err.statusCode || 500;
  logger.error(`Unhandled Error [${statusCode}]: ${err.message}`, { 
    ...logContext,
    ...reqInfo,
    stack: err.stack 
  });
  
  res.status(statusCode).json({
    success: false,
    error: {
      message: err.message || 'Internal server error',
      details: process.env.NODE_ENV === 'development' ? err.stack : 'Something went wrong',
      code: err.name || 'InternalServerError',
    },
  });
};

/**
 * 404 오류 처리 미들웨어
 * 일치하는 라우트가 없을 때 404 응답을 반환합니다.
 * 
 * @param {Object} req - Express 요청 객체
 * @param {Object} res - Express 응답 객체
 * @returns {void}
 */
exports.notFoundHandler = (req, res) => {
  logger.warn(`Not Found: ${req.method} ${req.originalUrl || req.url}`, {
    ip: req.ip,
    requestId: req.requestId,
  });
  
  res.status(404).json({
    success: false,
    error: {
      message: 'Endpoint not found',
      details: `The requested URL ${req.originalUrl || req.url} was not found on this server`,
      code: 'NotFoundError',
    },
  });
};

/**
 * 비동기 라우트 핸들러 래퍼
 * 비동기 라우트 핸들러에서 발생하는 오류를 캐치하여 errorHandler 미들웨어로 전달합니다.
 * 
 * @param {Function} fn - 비동기 라우트 핸들러 함수
 * @returns {Function} 오류 처리가 추가된 라우트 핸들러
 */
exports.asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};