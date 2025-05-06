const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const helmet = require('helmet');
const { createProxyMiddleware } = require('http-proxy-middleware');
const routes = require('./routes');
const logger = require('../../Shared/logger');
require('dotenv').config({ path: '../../Infrastructure/.env' });

// Initialize express app
const app = express();
const PORT = process.env.GATEWAY_PORT || 3000;

// Set middleware
app.use(cors());
app.use(helmet());

// Morgan 로깅 설정 변경 - 개발 환경에서만 상세 로깅
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined', {
    skip: (req, res) => res.statusCode < 400 // 성공적인 요청은 로깅하지 않음
  }));
}

// Health check and base routes
app.use('/', routes);

// Define service proxy configurations
const proxyConfigs = {
  auth: {
    path: '/api/auth',
    target: process.env.AUTH_SERVICE_URL || 'http://localhost:3001',
    pathRewrite: { '^/api/auth': '/api' }
  },
  consumer: {
    path: '/api/consumer',
    target: process.env.CONSUMER_SERVICE_URL || 'http://localhost:3002',
    pathRewrite: { '^/api/consumer': '/api' }
  },
  technician: {
    path: '/api/technician',
    target: process.env.TECHNICIAN_SERVICE_URL || 'http://localhost:3003',
    pathRewrite: { '^/api/technician': '/api' }
  },
  admin: {
    path: '/api/admin',
    target: process.env.ADMIN_SERVICE_URL || 'http://localhost:3004',
    pathRewrite: { '^/api/admin': '/api' }
  }
};

// Setup proxies
Object.keys(proxyConfigs).forEach(service => {
  const config = proxyConfigs[service];
  
  app.use(config.path, createProxyMiddleware({
    target: config.target,
    changeOrigin: true,
    pathRewrite: config.pathRewrite,
    logLevel: 'silent', // Log only errors
    timeout: 60000, // 60 seconds
    proxyTimeout: 120000, // 120 seconds
    
    onProxyReq: (proxyReq, req, res) => {
      // 디버그 로그는 필요한 경우에만 출력
      if (process.env.LOG_LEVEL === 'debug') {
        logger.debug(`Proxying ${req.method} ${req.originalUrl} to ${config.target}`);
      }
    },
    
    onProxyRes: (proxyRes, req, res) => {
      // 에러가 있거나 디버그 모드일 때만 로깅
      if (proxyRes.statusCode >= 400 || process.env.LOG_LEVEL === 'debug') {
        logger.debug(`Received ${proxyRes.statusCode} for ${req.method} ${req.originalUrl}`);
      }
    },
    
    onError: (err, req, res) => {
      logger.error(`Proxy error for ${req.method} ${req.originalUrl}:`, err);
      
      if (!res.headersSent) {
        res.status(502).json({
          success: false,
          message: `Service Unavailable: ${service} service`,
          error: process.env.NODE_ENV === 'development' ? err.message : 'Service temporarily unavailable'
        });
      }
    }
  }));
  
  // 시작할 때 한 번만 로깅
  console.log(`Proxy set up for ${service.toUpperCase()} service at ${config.path} -> ${config.target}`);
});

// Parse JSON only for routes not handled by proxies
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Global error handler
app.use((err, req, res, next) => {
  logger.error('Gateway error:', err);
  
  res.status(500).json({
    success: false,
    message: 'Internal Gateway Error',
    error: process.env.NODE_ENV === 'development' ? err.message : 'An unexpected error occurred'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Start server
app.listen(PORT, () => {
  // 콘솔에만 로깅하여 중복을 방지
  console.log(`=== API Gateway started ===`);
  console.log(`API Gateway running on port ${PORT}`);
  console.log(`API Gateway URL: http://localhost:${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`===========================`);
});

module.exports = app;