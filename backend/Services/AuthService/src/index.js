const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const logger = require('../../../Shared/logger');
const { sequelize } = require('../../../Shared/database');
require('dotenv').config({ path: '../../../Infrastructure/.env' });

const authRoutes = require('./routes/authRoutes');

const app = express();

// 미들웨어
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 요청 본문 로그 미들웨어 추가
app.use((req, res, next) => {
  if (req.method === 'POST') {
    logger.debug('Request body received:', req.body);
  }
  next();
});

// 라우트 - 다른 서비스와 일관성을 위해 /api 접두사 추가
app.use('/api', authRoutes);

// 기본 라우트
app.get('/', (req, res) => {
  res.json({ 
    success: true,
    message: 'Auth Service is running',
    version: '1.0.0' 
  });
});

// 에러 핸들링 미들웨어
app.use((err, req, res, next) => {
  logger.error('Error:', err);
  res.status(err.statusCode || 500).json({
    success: false,
    error: {
      message: err.message || 'Server error',
      details: process.env.NODE_ENV === 'development' ? err.stack : 'Internal server error'
    }
  });
});

// 404 에러 핸들링
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: {
      message: 'Endpoint not found',
      details: 'The requested resource does not exist'
    }
  });
});

// Model synchronization
const syncModels = async () => {
  try {
    // 개발 환경에서만 자동 동기화 (프로덕션에서는 마이그레이션 사용 권장)
    if (process.env.NODE_ENV !== 'production') {
      // { alter: true }: 변경된 스키마에 맞게 테이블 수정
      await sequelize.sync({ alter: true });
      logger.info('Database models synchronized');
    }
  } catch (error) {
    logger.error('Failed to synchronize database models:', error);
  }
};

// 서버 시작
const PORT = process.env.AUTH_SERVICE_PORT || 3001;

// 서버 시작 전에 모델 동기화 실행
syncModels().then(() => {
  app.listen(PORT, () => {
    logger.info(`Auth Service running on port ${PORT}`);
  });
});