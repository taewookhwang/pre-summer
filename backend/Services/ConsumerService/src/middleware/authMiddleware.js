const jwt = require('jsonwebtoken');
require('dotenv').config({ path: '../../../../Infrastructure/.env' });
const logger = require('../../../../Shared/logger');

/**
 * Authenticate user using JWT token
 */
exports.authenticateUser = (req, res, next) => {
  try {
    let token;
    
    // Extract token from request headers
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }
    
    // Check if token exists
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required. Please login.'
      });
    }
    
    try {
      // 개발 환경에서 테스트 토큰 처리
      if (process.env.NODE_ENV === 'development' && 
          (token.startsWith('test_token_') || token.startsWith('test_refresh_') || token.startsWith('test_refre'))) {
        logger.info('Using test token in development mode');
        
        // 테스트 토큰에서 사용자 역할과 ID 추출
        const parts = token.split('_');
        
        // 기본값 설정
        let role = 'consumer';
        let userId = 1; // 숫자로 설정 (중요)
        
        // 토큰 형식에 따라 다르게 처리
        if (parts.length > 2) {
          // 세 번째 부분이 role
          if (parts[2] !== 'token') { // "token"은 role 값이 아님
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
          name: `Test ${role.charAt(0).toUpperCase() + role.slice(1)}`
        };
        
        next();
        return;
      }
      
      // 실제 JWT 토큰 처리
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Set user info in request object
      req.user = {
        id: decoded.id,
        email: decoded.email,
        role: decoded.role,
        name: decoded.name
      };
      
      next();
    } catch (error) {
      logger.error('Token verification failed:', error);
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired token. Please login again.'
      });
    }
  } catch (error) {
    logger.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

/**
 * Restrict access to specific roles
 * @param {...string} roles - Allowed roles
 */
exports.restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'User not authenticated'
      });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Access denied. ${req.user.role} role is not authorized.`
      });
    }
    
    next();
  };
};