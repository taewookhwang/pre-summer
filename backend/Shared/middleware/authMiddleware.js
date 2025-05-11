/**
 * @fileoverview 인증 관련 공통 미들웨어
 * 
 * 모든 마이크로서비스에서 공통으로 사용하는 인증 미들웨어를 제공합니다.
 * JWT 기반 인증, 역할 기반 접근 제어 등의 기능을 포함합니다.
 * 
 * @module Shared/middleware/authMiddleware
 * @requires jsonwebtoken
 */

const jwt = require('jsonwebtoken');
const logger = require('../logger');
const config = require('../config');
const { UnauthorizedError, ForbiddenError } = require('../errors');

/**
 * JWT 토큰으로 사용자를 인증하는 미들웨어
 * 요청 헤더에서 Authorization 토큰을 확인하고 검증합니다.
 * 
 * @async
 * @param {Object} req - Express 요청 객체
 * @param {Object} res - Express 응답 객체
 * @param {Function} next - Express 다음 미들웨어 함수
 * @returns {void}
 */
exports.authenticateUser = async (req, res, next) => {
  try {
    let token;

    // 요청 헤더에서 토큰 추출
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    // 토큰이 없는 경우
    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required. Please login.',
          details: 'No authentication token provided',
        },
      });
    }

    try {
      // 개발 환경에서 테스트 토큰 처리
      if (
        config.app.isDev &&
        (token.startsWith('test_token_') ||
          token.startsWith('test_refresh_') ||
          token.startsWith('test_refre'))
      ) {
        logger.info('Using test token in development mode');

        // 테스트 토큰에서 사용자 역할과 ID 추출
        const parts = token.split('_');

        // 기본값 설정
        let role = 'consumer';
        let userId = 1; // 숫자로 설정 (중요)

        // 토큰 형식에 따라 다르게 처리
        if (parts.length > 2) {
          // 세 번째 부분이 role
          if (parts[2] !== 'token') {
            // "token"은 role 값이 아님
            role = parts[2];
          }
          if (parts.length > 3 && !isNaN(parseInt(parts[3]))) {
            userId = parseInt(parts[3]); // 문자열을 숫자로 변환 (중요)
          }
        }

        // 모의 사용자 정보 설정
        req.user = {
          id: userId,
          email: `test_${role}@example.com`,
          role: role,
          name: `Test ${role.charAt(0).toUpperCase() + role.slice(1)}`,
        };

        next();
        return;
      }

      // 실제 JWT 토큰 처리
      const decoded = jwt.verify(token, config.jwt.secret);

      // User 모델이 서비스마다 다를 수 있으므로, 여기서는 토큰 검증만 수행
      // 각 서비스에서 필요시 사용자 검증을 추가로 구현하도록 함
      req.user = {
        id: decoded.id,
        email: decoded.email,
        role: decoded.role,
        name: decoded.name,
      };

      next();
    } catch (error) {
      logger.error('Token verification failed:', error);
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid or expired token. Please login again.',
          details: error.message,
        },
      });
    }
  } catch (error) {
    logger.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      error: {
        message: 'Internal server error',
        details: error.message,
      },
    });
  }
};

/**
 * 특정 역할의 사용자만 접근 가능하도록 하는 미들웨어
 * 
 * @param {...string} roles - 허용된 역할 목록
 * @returns {Function} Express 미들웨어 함수
 */
exports.restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'User not authenticated',
          details: 'Authentication required',
        },
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: {
          message: 'Access denied. Insufficient permissions.',
          details: `User role '${req.user.role}' is not authorized to access this route`,
        },
      });
    }

    next();
  };
};

/**
 * 요청 객체에서 현재 사용자의 ID를 추출하는 유틸리티 함수
 * 
 * @param {Object} req - Express 요청 객체
 * @returns {number|string|null} 사용자 ID 또는 인증되지 않은 경우 null
 */
exports.getCurrentUserId = (req) => {
  return req.user ? req.user.id : null;
};

/**
 * 요청 객체에서 현재 사용자의 역할을 추출하는 유틸리티 함수
 * 
 * @param {Object} req - Express 요청 객체
 * @returns {string|null} 사용자 역할 또는 인증되지 않은 경우 null
 */
exports.getCurrentUserRole = (req) => {
  return req.user ? req.user.role : null;
};

/**
 * 리소스 소유자인지 확인하는 미들웨어
 * 요청 객체의 사용자 ID와 리소스의 사용자 ID가 일치하는지 확인합니다.
 * 
 * @param {Function} getResourceOwnerId - 리소스 소유자 ID를 가져오는 함수
 * @param {boolean} [allowAdmin=true] - 관리자 접근 허용 여부
 * @returns {Function} Express 미들웨어 함수 
 */
exports.checkResourceOwner = (getResourceOwnerId, allowAdmin = true) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: {
            message: 'User not authenticated',
            details: 'Authentication required',
          },
        });
      }

      // 관리자 허용 옵션이 켜져 있고 사용자가 관리자인 경우 바로 통과
      if (allowAdmin && req.user.role === 'admin') {
        return next();
      }

      // 함수를 통해 리소스 소유자 ID 가져오기
      const resourceOwnerId = await getResourceOwnerId(req);

      // ID를 숫자로 변환하여 비교 (데이터 타입 불일치 방지)
      if (parseInt(req.user.id) !== parseInt(resourceOwnerId)) {
        return res.status(403).json({
          success: false,
          error: {
            message: 'Access denied. You do not own this resource.',
            details: 'You can only access your own resources',
          },
        });
      }

      next();
    } catch (error) {
      logger.error('CheckResourceOwner middleware error:', error);
      return res.status(500).json({
        success: false,
        error: {
          message: 'Internal server error',
          details: error.message,
        },
      });
    }
  };
};