/**
 * @fileoverview 공통 미들웨어 모듈
 * 
 * 모든 마이크로서비스에서 사용할 수 있는 공통 미들웨어를 제공합니다.
 * 
 * @module Shared/middleware
 */

const authMiddleware = require('./authMiddleware');
const errorMiddleware = require('./errorMiddleware');
const requestLoggerMiddleware = require('./requestLoggerMiddleware');

/**
 * Express 애플리케이션에 기본 미들웨어를 등록합니다.
 * 
 * @param {Object} app - Express 애플리케이션 인스턴스
 * @returns {void}
 */
const applyDefaultMiddleware = (app) => {
  // 요청 로깅 미들웨어 적용
  app.use(requestLoggerMiddleware);
  
  // 에러 핸들링 미들웨어는 다른 모든 미들웨어 뒤에 적용해야 합니다.
  // 따라서 이 함수는 라우터 설정 후에 별도로 호출해야 합니다.
};

/**
 * Express 애플리케이션에 에러 처리 미들웨어를 등록합니다.
 * 모든 라우트 정의 후 마지막에 적용해야 합니다.
 * 
 * @param {Object} app - Express 애플리케이션 인스턴스
 * @returns {void}
 */
const applyErrorHandlers = (app) => {
  // 404 처리 미들웨어 (정의된 라우트가 없는 경우)
  app.use(errorMiddleware.notFoundHandler);
  
  // 오류 처리 미들웨어 (가장 마지막에 적용)
  app.use(errorMiddleware.errorHandler);
};

module.exports = {
  auth: authMiddleware,
  error: errorMiddleware,
  requestLogger: requestLoggerMiddleware,
  asyncHandler: errorMiddleware.asyncHandler,
  applyDefaultMiddleware,
  applyErrorHandlers,
};