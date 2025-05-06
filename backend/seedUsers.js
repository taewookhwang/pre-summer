// 유저 데이터 시드 스크립트
const { sequelize } = require('./Shared/database');
const logger = require('./Shared/logger');
const path = require('path');
const bcrypt = require('bcrypt');
require('dotenv').config({ path: path.join(__dirname, 'Infrastructure/.env') });

// User 모델은 AuthService에 있어야 합니다
const User = require('./Services/AuthService/src/models/User');

// 비밀번호 해시화
const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
};

// 유저 데이터 추가
const seedUsers = async () => {
  try {
    // DB 연결 확인
    await sequelize.authenticate();
    logger.info('Database connection established successfully.');

    // 기본 비밀번호 해시
    const passwordHash = await hashPassword('password123');

    // 유저 데이터
    const users = [
      {
        email: 'admin@example.com',
        password_hash: passwordHash,
        role: 'admin',
        name: '관리자',
        phone: '010-1234-5678',
        address: '서울시 강남구',
        is_active: true
      },
      {
        email: 'consumer@example.com',
        password_hash: passwordHash,
        role: 'consumer',
        name: '홍길동',
        phone: '010-1111-2222',
        address: '서울시 서초구',
        is_active: true
      },
      {
        email: 'technician@example.com',
        password_hash: passwordHash,
        role: 'technician',
        name: '김청소',
        phone: '010-3333-4444',
        address: '서울시 용산구',
        is_active: true
      }
    ];

    // 유저 데이터 생성
    for (const userData of users) {
      const [user, created] = await User.findOrCreate({
        where: { email: userData.email },
        defaults: userData
      });

      if (created) {
        logger.info(`유저 생성 완료: ${user.email} (${user.role})`);
      } else {
        logger.info(`이미 존재하는 유저: ${user.email} (${user.role})`);
      }
    }

    logger.info('유저 데이터 추가 완료');
    await sequelize.close();
  } catch (error) {
    logger.error('유저 데이터 추가 중 오류 발생:', error);
  }
};

// 스크립트 실행
seedUsers();