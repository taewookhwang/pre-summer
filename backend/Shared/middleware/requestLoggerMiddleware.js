/**
 * @fileoverview 요청 로깅 미들웨어
 * 
 * HTTP 요청과 응답을 로깅하는 공통 미들웨어를 제공합니다.
 * 각 요청에 고유 식별자를 부여하고 요청/응답 정보를 로깅합니다.
 * 
 * @module Shared/middleware/requestLoggerMiddleware
 */

const { v4: uuidv4 } = require('uuid');
const logger = require('../logger');

/**
 * HTTP 요청 로깅 미들웨어
 * 각 요청에 고유 ID를 할당하고 요청/응답 정보를 로깅합니다.
 * 
 * @param {Object} req - Express 요청 객체
 * @param {Object} res - Express 응답 객체
 * @param {Function} next - Express 다음 미들웨어 함수
 * @returns {void}
 */
const requestLogger = (req, res, next) => {
  // 요청 ID 생성 또는 헤더에서 가져오기
  const requestId = req.headers['x-request-id'] || uuidv4();
  req.requestId = requestId;
  
  // 응답 헤더에 요청 ID 추가
  res.setHeader('X-Request-ID', requestId);
  
  // 요청 시작 시간 기록
  const startTime = process.hrtime();
  
  // 요청 정보 로깅
  logger.http(`Request: ${req.method} ${req.originalUrl || req.url}`, {
    requestId,
    method: req.method,
    url: req.originalUrl || req.url,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    userId: req.user?.id, // 인증 미들웨어 실행 후 사용자 정보가 있는 경우
  });
  
  // 민감한 데이터를 제외한 요청 본문 로깅 (개발 환경에서만)
  if (process.env.NODE_ENV === 'development' && req.method !== 'GET') {
    // 민감한 필드 마스킹
    const sanitizedBody = getSanitizedBody(req.body);
    if (Object.keys(sanitizedBody).length > 0) {
      logger.debug('Request body:', {
        requestId,
        body: sanitizedBody,
      });
    }
  }
  
  // 응답 완료 후 로깅을 위한 응답 이벤트 리스너
  res.on('finish', () => {
    // 응답 시간 계산 (밀리초)
    const [seconds, nanoseconds] = process.hrtime(startTime);
    const responseTimeMs = (seconds * 1000 + nanoseconds / 1000000).toFixed(2);
    
    // 상태 코드에 따라 로그 레벨 결정
    const level = res.statusCode >= 500 ? 'error' : 
                 res.statusCode >= 400 ? 'warn' : 
                 'http';
    
    // 응답 정보 로깅
    logger[level](`Response: ${req.method} ${req.originalUrl || req.url} ${res.statusCode} ${responseTimeMs}ms`, {
      requestId,
      method: req.method,
      url: req.originalUrl || req.url,
      statusCode: res.statusCode,
      responseTime: responseTimeMs,
      contentLength: res.getHeader('content-length'),
    });
  });
  
  next();
};

/**
 * 요청 본문에서 민감한 정보를 제거하거나 마스킹합니다.
 * 
 * @param {Object} body - 요청 본문 객체
 * @returns {Object} 민감 정보가 제거된 본문 객체
 * @private
 */
function getSanitizedBody(body) {
  if (!body || typeof body !== 'object') {
    return body;
  }
  
  const sensitiveFields = [
    'password', 'password_hash', 'passwordHash', 'secret', 'token', 
    'accessToken', 'refreshToken', 'cardNumber', 'cvv', 'pin'
  ];
  
  const sanitized = JSON.parse(JSON.stringify(body));
  
  // 민감한 필드 마스킹
  Object.keys(sanitized).forEach(key => {
    if (sensitiveFields.includes(key.toLowerCase())) {
      sanitized[key] = '******';
    } else if (typeof sanitized[key] === 'object' && sanitized[key] !== null) {
      sanitized[key] = getSanitizedBody(sanitized[key]);
    }
  });
  
  return sanitized;
}

module.exports = requestLogger;