const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const bodyParser = require('body-parser');
const routes = require('./routes');
const logger = require('../../../Shared/logger');
const { sequelize } = require('../../../Shared/database');
require('dotenv').config({ path: '../../../Infrastructure/.env' });

// Initialize express app
const app = express();

// Set middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Set routes
app.use('/api', routes);

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error(`Error: ${err.message}`);
  
  res.status(err.statusCode || 500).json({
    success: false,
    error: {
      message: err.message || 'Server Error',
      details: process.env.NODE_ENV === 'development' ? err.stack : 'Internal server error'
    }
  });
});

// Handle 404 errors
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

// Set port and start server
const PORT = process.env.ADMIN_SERVICE_PORT || 3004;

// 서버 시작 전에 모델 동기화 실행
syncModels().then(() => {
  app.listen(PORT, () => {
    logger.info(`AdminService running on port ${PORT}`);
  });
});

module.exports = app;