const express = require('express');
const router = express.Router();

// 0ø ½\ - D¤ ÁÜ Ux©
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

// D¤ ÁÜ Ux ÔÜìx¸
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API Gateway is up and running',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;