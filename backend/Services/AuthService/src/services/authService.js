const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const logger = require('../../../../Shared/logger');
require('dotenv').config({ path: '../../../../Infrastructure/.env' });

/**
 * 인증 관련 서비스 클래스
 */
class AuthService {
  /**
   * 사용자 등록 서비스
   * @param {Object} userData - 사용자 등록 데이터
   * @returns {Promise<Object>} 등록된 사용자 및 토큰 정보
   */
  async registerUser(userData) {
    try {
      logger.debug('Starting user registration process for:', userData.email);
      
      const { email, password, role, name, phone, address } = userData;

      // 이메일 중복 확인
      logger.debug('Checking if user already exists:', email);
      const existingUser = await User.findOne({ where: { email } });
      
      if (existingUser) {
        logger.debug('User with email already exists:', email);
        const error = new Error('User with this email already exists');
        error.statusCode = 400;
        throw error;
      }
      
      logger.debug('User does not exist, proceeding with registration');

      // 비밀번호 해싱
      logger.debug('Hashing password');
      const salt = await bcrypt.genSalt(10);
      const password_hash = await bcrypt.hash(password, salt);
      
      logger.debug('Creating new user in database');
      // 사용자 생성
      const newUser = await User.create({
        email,
        password_hash,
        role,
        name,
        phone,
        address
      });
      
      logger.debug('User created successfully with ID:', newUser.id);

      // 토큰 생성
      logger.debug('Generating tokens');
      const token = this.generateAccessToken(newUser);
      const refreshToken = this.generateRefreshToken(newUser);
      
      logger.debug('Registration process completed successfully');

      return {
        user: {
          id: newUser.id,
          email: newUser.email,
          role: newUser.role,
          name: newUser.name
        },
        token,
        refreshToken
      };
    } catch (error) {
      logger.error('Error in registerUser service:', error);
      // 오류에 상태 코드가 없으면 추가
      if (!error.statusCode) {
        error.statusCode = 500;
      }
      throw error;
    }
  }

  /**
   * 사용자 로그인 서비스
   * @param {string} email - 사용자 이메일
   * @param {string} password - 사용자 비밀번호
   * @returns {Promise<Object>} 로그인된 사용자 및 토큰 정보
   */
  async loginUser(email, password) {
    try {
      logger.debug('Starting login process for:', email);
      
      // 이메일로 사용자 찾기
      logger.debug('Finding user by email');
      const user = await User.findOne({ where: { email } });
      
      if (!user) {
        logger.debug('User not found with email:', email);
        const error = new Error('Invalid credentials');
        error.statusCode = 401;
        throw error;
      }

      // 비밀번호 확인
      logger.debug('Verifying password');
      const isMatch = await bcrypt.compare(password, user.password_hash);
      
      if (!isMatch) {
        logger.debug('Password verification failed for user:', email);
        const error = new Error('Invalid credentials');
        error.statusCode = 401;
        throw error;
      }

      // 토큰 생성
      logger.debug('Password verified, generating tokens');
      const token = this.generateAccessToken(user);
      const refreshToken = this.generateRefreshToken(user);
      
      logger.debug('Login process completed successfully');

      return {
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
          name: user.name
        },
        token,
        refreshToken
      };
    } catch (error) {
      logger.error('Error in loginUser service:', error);
      if (!error.statusCode) {
        error.statusCode = 500;
      }
      throw error;
    }
  }

  /**
   * 토큰 갱신 서비스
   * @param {string} refreshToken - 리프레시 토큰
   * @returns {Promise<Object>} 새로운 액세스 토큰
   */
  async refreshUserToken(refreshToken) {
    try {
      logger.debug('Starting token refresh process');
      
      if (!refreshToken) {
        logger.debug('No refresh token provided');
        const error = new Error('Refresh token is required');
        error.statusCode = 401;
        throw error;
      }

      // 개발 환경에서 테스트 토큰 처리 - iOS 앱 테스트 용도
      if (process.env.NODE_ENV === 'development' && 
          (refreshToken.startsWith('test_refresh_') || refreshToken.startsWith('test_token_') || refreshToken.startsWith('test_refre'))) {
        logger.debug('Development mode - Using test refresh token');
        
        // 테스트 토큰에서 사용자 역할과 ID 추출
        // 형식1: test_refresh_consumer_123
        // 형식2: test_token_consumer_123
        // 형식3: test_refre...
        const parts = refreshToken.split('_');
        
        // 기본값 설정
        let role = 'consumer';
        let userId = '1';
        
        // 토큰 형식에 따라 다르게 처리
        if (parts.length > 2) {
          // 세 번째 부분이 role
          if (parts[2] !== 'token') { // "token"은 role 값이 아님
            role = parts[2];
          }
          if (parts.length > 3) {
            userId = parts[3];
          }
        }
        
        logger.debug(`Dev test: Using role=${role}, userId=${userId}`);
        
        // 테스트 환경에서는 DB 쿼리 없이 바로 모의 사용자 객체 생성
        logger.debug('Creating mock user object for test token');
        // 모의 사용자 객체 생성
        const user = {
          id: userId,
          email: `test_${role}@example.com`,
          role: role
        };
        
        // 테스트용 액세스 토큰 생성
        logger.debug('Generating test access token');
        const token = this.generateAccessToken(user);
        
        logger.debug('Test token refresh completed successfully');
        return { token };
      }

      // 실제 JWT 토큰 처리 - 프로덕션 환경
      try {
        // 토큰 검증
        logger.debug('Verifying refresh token');
        const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
        
        // 사용자 찾기
        logger.debug('Finding user with ID:', decoded.id);
        const user = await User.findByPk(decoded.id);
        
        if (!user) {
          logger.debug('User not found for token with ID:', decoded.id);
          const error = new Error('Invalid token');
          error.statusCode = 401;
          throw error;
        }

        // 새 액세스 토큰 생성
        logger.debug('Generating new access token');
        const token = this.generateAccessToken(user);
        
        logger.debug('Token refresh completed successfully');
        return { token };
      } catch (jwtError) {
        logger.error('JWT verification error:', jwtError);
        if (jwtError.name === 'JsonWebTokenError' || jwtError.name === 'TokenExpiredError') {
          const customError = new Error('Invalid or expired token');
          customError.statusCode = 401;
          throw customError;
        }
        throw jwtError;
      }
    } catch (error) {
      logger.error('Error in refreshUserToken service:', error);
      if (!error.statusCode) {
        error.statusCode = 500;
      }
      throw error;
    }
  }

  /**
   * 사용자 정보 조회 서비스
   * @param {number} userId - 사용자 ID
   * @returns {Promise<Object>} 사용자 정보
   */
  async getUserById(userId) {
    try {
      logger.debug('Getting user information for ID:', userId);
      
      const user = await User.findByPk(userId, {
        attributes: { exclude: ['password_hash'] }
      });
      
      if (!user) {
        logger.debug('User not found with ID:', userId);
        const error = new Error('User not found');
        error.statusCode = 404;
        throw error;
      }
      
      logger.debug('User found successfully');
      return user;
    } catch (error) {
      logger.error('Error in getUserById service:', error);
      if (!error.statusCode) {
        error.statusCode = 500;
      }
      throw error;
    }
  }

  /**
   * 액세스 토큰 생성 함수
   * @param {Object} user - 사용자 객체
   * @returns {string} JWT 액세스 토큰
   */
  generateAccessToken(user) {
    try {
      return jwt.sign(
        { id: user.id, email: user.email, role: user.role },
        process.env.JWT_SECRET || 'fallback_secret_do_not_use_in_production',
        { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
      );
    } catch (error) {
      logger.error('Error generating access token:', error);
      throw new Error('Failed to generate access token');
    }
  }

  /**
   * 리프레시 토큰 생성 함수
   * @param {Object} user - 사용자 객체
   * @returns {string} JWT 리프레시 토큰
   */
  generateRefreshToken(user) {
    try {
      return jwt.sign(
        { id: user.id },
        process.env.JWT_SECRET || 'fallback_secret_do_not_use_in_production',
        { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
      );
    } catch (error) {
      logger.error('Error generating refresh token:', error);
      throw new Error('Failed to generate refresh token');
    }
  }
}

module.exports = new AuthService();