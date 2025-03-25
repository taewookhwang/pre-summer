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
  const { email, password, role, name, phone, address } = userData;

  // 이메일 중복 확인
  const existingUser = await User.findOne({ where: { email } });
  if (existingUser) {
    const error = new Error('User with this email already exists');
    error.statusCode = 400;
    throw error;
  }

  // 비밀번호 해싱
  const salt = await bcrypt.genSalt(10);
  const password_hash = await bcrypt.hash(password, salt);

  // 사용자 생성
  const newUser = await User.create({
    email,
    password_hash,
    role,
    name,
    phone,
    address
  });

  // 토큰 생성
  const token = generateAccessToken(newUser);
  const refreshToken = generateRefreshToken(newUser);

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
};

/**
 * 사용자 로그인 서비스
 * @param {string} email - 사용자 이메일
 * @param {string} password - 사용자 비밀번호
 * @returns {Promise<Object>} 로그인된 사용자 및 토큰 정보
 */
exports.loginUser = async (email, password) => {
  // 이메일로 사용자 찾기
  const user = await User.findOne({ where: { email } });
  if (!user) {
    const error = new Error('Invalid credentials');
    error.statusCode = 401;
    throw error;
  }

  // 비밀번호 확인
  const isMatch = await bcrypt.compare(password, user.password_hash);
  if (!isMatch) {
    const error = new Error('Invalid credentials');
    error.statusCode = 401;
    throw error;
  }

  // 토큰 생성
  const token = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

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
};

/**
 * 토큰 갱신 서비스
 * @param {string} refreshToken - 리프레시 토큰
 * @returns {Promise<Object>} 새로운 액세스 토큰
 */
exports.refreshUserToken = async (refreshToken) => {
  if (!refreshToken) {
    const error = new Error('Refresh token is required');
    error.statusCode = 401;
    throw error;
  }

  try {
    // 토큰 검증
    const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
    
    // 사용자 찾기
    const user = await User.findByPk(decoded.id);
    if (!user) {
      const error = new Error('Invalid token');
      error.statusCode = 401;
      throw error;
    }

    // 새 액세스 토큰 생성
    const token = generateAccessToken(user);

    return { token };
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      const customError = new Error('Invalid or expired token');
      customError.statusCode = 401;
      throw customError;
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
  const user = await User.findByPk(userId, {
    attributes: { exclude: ['password_hash'] }
  });
  
  if (!user) {
    const error = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }
  
  return user;
};

/**
 * 액세스 토큰 생성 함수
 * @param {Object} user - 사용자 객체
 * @returns {string} JWT 액세스 토큰
 */
const generateAccessToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1h' }
  );
};

/**
 * 리프레시 토큰 생성 함수
 * @param {Object} user - 사용자 객체
 * @returns {string} JWT 리프레시 토큰
 */
const generateRefreshToken = (user) => {
  return jwt.sign(
    { id: user.id },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
  );
};