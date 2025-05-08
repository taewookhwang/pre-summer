const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
require('dotenv').config({ path: '../../../../Infrastructure/.env' });

/**
 * 사용자 등록 서비스
 * @param {Object} userData - 사용자 등록 데이터
 * @returns {Promise<Object>} 등록된 사용자 및 토큰 정보
 */
exports.registerUser = async (userData) => {
  try {
    console.log('Starting user registration process for:', userData.email);
    
    const { email, password, role, name, phone, address } = userData;

    // 이메일 중복 확인
    console.log('Checking if user already exists:', email);
    const existingUser = await User.findOne({ where: { email } });
    
    if (existingUser) {
      console.log('User with email already exists:', email);
      const error = new Error('User with this email already exists');
      error.statusCode = 400;
      throw error;
    }
    
    console.log('User does not exist, proceeding with registration');

    // 비밀번호 해싱
    console.log('Hashing password');
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);
    
    console.log('Creating new user in database');
    // 사용자 생성
    const newUser = await User.create({
      email,
      password_hash,
      role,
      name,
      phone,
      address
    });
    
    console.log('User created successfully with ID:', newUser.id);

    // 토큰 생성
    console.log('Generating tokens');
    const token = generateAccessToken(newUser);
    const refreshToken = generateRefreshToken(newUser);
    
    console.log('Registration process completed successfully');

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
    console.error('Error in registerUser service:', error);
    // 오류에 상태 코드가 없으면 추가
    if (!error.statusCode) {
      error.statusCode = 500;
    }
    throw error;
  }
};

/**
 * 사용자 로그인 서비스
 * @param {string} email - 사용자 이메일
 * @param {string} password - 사용자 비밀번호
 * @returns {Promise<Object>} 로그인된 사용자 및 토큰 정보
 */
exports.loginUser = async (email, password) => {
  try {
    console.log('Starting login process for:', email);
    
    // 이메일로 사용자 찾기
    console.log('Finding user by email');
    const user = await User.findOne({ where: { email } });
    
    if (!user) {
      console.log('User not found with email:', email);
      const error = new Error('Invalid credentials');
      error.statusCode = 401;
      throw error;
    }

    // 비밀번호 확인
    console.log('Verifying password');
    const isMatch = await bcrypt.compare(password, user.password_hash);
    
    if (!isMatch) {
      console.log('Password verification failed for user:', email);
      const error = new Error('Invalid credentials');
      error.statusCode = 401;
      throw error;
    }

    // 토큰 생성
    console.log('Password verified, generating tokens');
    const token = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);
    
    console.log('Login process completed successfully');

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
    console.error('Error in loginUser service:', error);
    if (!error.statusCode) {
      error.statusCode = 500;
    }
    throw error;
  }
};

/**
 * 토큰 갱신 서비스
 * @param {string} refreshToken - 리프레시 토큰
 * @returns {Promise<Object>} 새로운 액세스 토큰
 */
exports.refreshUserToken = async (refreshToken) => {
  try {
    console.log('Starting token refresh process');
    
    if (!refreshToken) {
      console.log('No refresh token provided');
      const error = new Error('Refresh token is required');
      error.statusCode = 401;
      throw error;
    }

    // 개발 환경에서 테스트 토큰 처리 - iOS 앱 테스트 용도
    if (process.env.NODE_ENV === 'development' && refreshToken.startsWith('test_refresh_')) {
      console.log('Development mode - Using test refresh token');
      
      // 테스트 토큰에서 사용자 역할과 ID 추출 (예: test_refresh_consumer_123)
      const parts = refreshToken.split('_');
      const role = parts.length > 2 ? parts[2] : 'consumer';
      const userId = parts.length > 3 ? parts[3] : '1';
      
      console.log(`Dev test: Using role=${role}, userId=${userId}`);
      
      // 해당 역할을 가진 사용자 찾기 또는 생성
      let user = await User.findOne({ where: { role } });
      
      if (!user) {
        // 테스트용 사용자가 없으면 첫 번째 사용자 가져오기
        user = await User.findByPk(1);
        
        if (!user) {
          console.log('No test user found - Creating mock user object');
          // 모의 사용자 객체 생성
          user = {
            id: userId,
            email: `test_${role}@example.com`,
            role: role
          };
        }
      }
      
      // 테스트용 액세스 토큰 생성
      console.log('Generating test access token');
      const token = generateAccessToken(user);
      
      console.log('Test token refresh completed successfully');
      return { token };
    }

    // 실제 JWT 토큰 처리 - 프로덕션 환경
    try {
      // 토큰 검증
      console.log('Verifying refresh token');
      const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
      
      // 사용자 찾기
      console.log('Finding user with ID:', decoded.id);
      const user = await User.findByPk(decoded.id);
      
      if (!user) {
        console.log('User not found for token with ID:', decoded.id);
        const error = new Error('Invalid token');
        error.statusCode = 401;
        throw error;
      }

      // 새 액세스 토큰 생성
      console.log('Generating new access token');
      const token = generateAccessToken(user);
      
      console.log('Token refresh completed successfully');
      return { token };
    } catch (jwtError) {
      console.error('JWT verification error:', jwtError);
      if (jwtError.name === 'JsonWebTokenError' || jwtError.name === 'TokenExpiredError') {
        const customError = new Error('Invalid or expired token');
        customError.statusCode = 401;
        throw customError;
      }
      throw jwtError;
    }
  } catch (error) {
    console.error('Error in refreshUserToken service:', error);
    if (!error.statusCode) {
      error.statusCode = 500;
    }
    throw error;
  }
};

/**
 * 사용자 정보 조회 서비스
 * @param {number} userId - 사용자 ID
 * @returns {Promise<Object>} 사용자 정보
 */
exports.getUserById = async (userId) => {
  try {
    console.log('Getting user information for ID:', userId);
    
    const user = await User.findByPk(userId, {
      attributes: { exclude: ['password_hash'] }
    });
    
    if (!user) {
      console.log('User not found with ID:', userId);
      const error = new Error('User not found');
      error.statusCode = 404;
      throw error;
    }
    
    console.log('User found successfully');
    return user;
  } catch (error) {
    console.error('Error in getUserById service:', error);
    if (!error.statusCode) {
      error.statusCode = 500;
    }
    throw error;
  }
};

/**
 * 액세스 토큰 생성 함수
 * @param {Object} user - 사용자 객체
 * @returns {string} JWT 액세스 토큰
 */
const generateAccessToken = (user) => {
  try {
    return jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      process.env.JWT_SECRET || 'fallback_secret_do_not_use_in_production',
      { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
    );
  } catch (error) {
    console.error('Error generating access token:', error);
    throw new Error('Failed to generate access token');
  }
};

/**
 * 리프레시 토큰 생성 함수
 * @param {Object} user - 사용자 객체
 * @returns {string} JWT 리프레시 토큰
 */
const generateRefreshToken = (user) => {
  try {
    return jwt.sign(
      { id: user.id },
      process.env.JWT_SECRET || 'fallback_secret_do_not_use_in_production',
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
    );
  } catch (error) {
    console.error('Error generating refresh token:', error);
    throw new Error('Failed to generate refresh token');
  }
};