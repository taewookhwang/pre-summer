const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const { sequelize } = require('../../../Shared/database');
const logger = require('../../../Shared/logger');
const matchingRoutes = require('./routes/matchingRoutes');

// Express 앱 초기화
const app = express();

// 미들웨어 설정
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// 라우트 등록
app.use('/api/matchings', matchingRoutes);

// 루트 라우트
app.get('/', (req, res) => {
  res.status(200).send({
    message: 'Welcome to Matching Service API',
  });
});

// 에러 핸들링 미들웨어
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).send({
    success: false,
    error: {
      message: err.message || 'Internal Server Error',
      details: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    },
  });
});

// 포트 설정
const PORT = process.env.MATCHING_SERVICE_PORT || 3004;

// 서버 시작
const startServer = async () => {
  try {
    // 데이터베이스 연결 확인
    await sequelize.authenticate();
    logger.info('Database connection has been established successfully.');

    // 모델 동기화
    // 주의: force 옵션은 개발 환경에서만 사용하세요.
    await sequelize.sync({ force: false });
    logger.info('Models synchronized with database.');

    // 서버 시작
    app.listen(PORT, () => {
      logger.info(`Matching Service running on port ${PORT}`);
    });
  } catch (error) {
    logger.error('Unable to start server:', error);
    process.exit(1);
  }
};

// 서버 시작 호출
startServer();
