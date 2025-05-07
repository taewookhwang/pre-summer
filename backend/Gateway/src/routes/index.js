const express = require('express');
const router = express.Router();

// 메인 라우트 - 게이트웨이 상태 및 서비스 정보 제공
router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Home Cleaning API Gateway is running',
    timestamp: new Date().toISOString(),
    services: {
      auth: process.env.AUTH_SERVICE_URL || 'http://localhost:3001',
      consumer: process.env.CONSUMER_SERVICE_URL || 'http://localhost:3002',
      technician: process.env.TECHNICIAN_SERVICE_URL || 'http://localhost:3003',
      admin: process.env.ADMIN_SERVICE_URL || 'http://localhost:3004'
    }
  });
});

// 헬스 체크 엔드포인트
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API Gateway is up and running',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;