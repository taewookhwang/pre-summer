const jwt = require('jsonwebtoken');
const logger = require('../../../../Shared/logger');

// JWT 시크릿 키
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

/**
 * 인증 미들웨어
 */
const authMiddleware = {
  /**
   * 사용자 인증
   */
  authenticateUser: (req, res, next) => {
    try {
      // Authorization 헤더에서 토큰 추출
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
          success: false,
          error: {
            message: 'No token provided',
          },
        });
      }

      const token = authHeader.split(' ')[1];

      // 토큰 검증
      jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
          return res.status(401).json({
            success: false,
            error: {
              message: 'Invalid or expired token',
            },
          });
        }

        // 검증된 사용자 정보를 요청 객체에 저장
        req.user = decoded;
        next();
      });
    } catch (error) {
      logger.error('Authentication error:', error);
      return res.status(401).json({
        success: false,
        error: {
          message: 'Authentication failed',
        },
      });
    }
  },

  /**
   * 역할 기반 접근 제어
   * @param {String} role - 필요한 역할
   */
  restrictTo: (role) => {
    return (req, res, next) => {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          error: {
            message: 'Authentication required',
          },
        });
      }

      if (req.user.role !== role && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          error: {
            message: 'Access denied',
          },
        });
      }

      next();
    };
  },
};

module.exports = authMiddleware;
