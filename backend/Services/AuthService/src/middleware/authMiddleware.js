const jwt = require('jsonwebtoken');
const User = require('../models/User');
require('dotenv').config({ path: '../../../../Infrastructure/.env' });
const logger = require('../../../../Shared/logger');

/**
 * JWT 토큰으로 사용자 인증하는 미들웨어
 * 요청 헤더에서 Authorization 토큰을 확인하고 검증합니다.
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
      // 토큰 검증
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // 사용자 정보 조회 및 req 객체에 추가
      const user = await User.findByPk(decoded.id);

      if (!user) {
        return res.status(401).json({
          success: false,
          error: {
            message: 'Invalid token. User not found.',
            details: 'User associated with this token no longer exists',
          },
        });
      }

      // req 객체에 사용자 정보 저장
      req.user = {
        id: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
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
    res.status(500).json({
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
 * @param {...string} roles - 허용된 역할 목록
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
