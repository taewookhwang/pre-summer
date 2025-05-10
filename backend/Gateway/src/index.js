// Gateway/index.js with enhanced debugging
const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');
require('dotenv').config();

const app = express();                                                                 //서버 인스턴스 생성(허브)(관제탑)
const PORT = process.env.GATEWAY_PORT || 3000;

// Middleware
app.use(cors());                                                                       //어떤 과정(순서 중요)을 거칠지
// body 파싱 미들웨어를 프록시 라우트 뒤로 이동                    //프록시와 라우팅, 핸들러, 미들웨어는 모두 인스턴스에 연결된다. 따라서 순서 중요
app.use(morgan('dev')); // 모든 요청에 대한 기본 로그                     // 과정을 거치고 가느냐 그냥 가느냐는 다르다.

// Root endpoint for basic connectivity test

// 프록시 미들웨어 등록 전 로그
console.log('프록시 미들웨어 등록 전');

// 공통 프록시 설정 옵션 정의
const createProxyOptions = (targetPort, pathRewrite, serviceName) => ({
  target: `http://127.0.0.1:${targetPort}`,
  changeOrigin: true,
  pathRewrite: pathRewrite,
  logLevel: 'debug',
  timeout: 60000, // 60초로 늘림
  proxyTimeout: 120000, // 120초로 늘림
  onProxyReq: (proxyReq, req, res) => {
    console.log(`프록시 요청 시작: ${proxyReq.method} ${proxyReq.path}`);
    console.log('프록시 대상:', proxyReq._headers.host);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`프록시 응답 수신: ${proxyRes.statusCode}`);
    console.log('응답 헤더:', JSON.stringify(proxyRes.headers, null, 2));
  },
  onError: (err, req, res) => {
    console.error(`프록시 오류 발생 (${serviceName}):`, err.message);
    console.error('상세 오류:', err.stack);
    console.error('요청 URL:', req.originalUrl);
    console.error('요청 Method:', req.method);
    console.error('요청 Headers:', req.headers);
    if (!res.headersSent) {
      res.status(502).json({
        error: `${serviceName} 연결 실패`,
        message: err.message,
        code: 'PROXY_ERROR',
        timestamp: new Date().toISOString()
      });
    }
  }
});

// 요청 로깅 미들웨어 생성 함수
const createRequestLogger = (serviceName) => (req, res, next) => {
  console.log(`==== ${serviceName} REQUEST RECEIVED ====`);
  console.log('Timestamp:', new Date().toISOString());
  console.log('Method:', req.method);
  console.log('Full URL:', req.originalUrl);
  console.log('Path:', req.url);
  console.log('Headers:', JSON.stringify(req.headers, null, 2));
  console.log('============================');
  next();
};

// Auth Service 프록시
app.use('/api/auth', 
  createRequestLogger('AUTH'),
  createProxyMiddleware(
    createProxyOptions(
      process.env.AUTH_SERVICE_PORT || 3001,
      { '^/api/auth': '' },
      'Auth Service'
    )
  )
);

// Consumer Service 프록시
app.use('/api/consumer',
  createRequestLogger('CONSUMER'),
  createProxyMiddleware(
    createProxyOptions(
      process.env.CONSUMER_SERVICE_PORT || 3002,
      { '^/api/consumer': '' },
      'Consumer Service'
    )
  )
);

// Technician Service 프록시
app.use('/api/technician',
  createRequestLogger('TECHNICIAN'),
  createProxyMiddleware(
    createProxyOptions(
      process.env.TECHNICIAN_SERVICE_PORT || 3003,
      { '^/api/technician': '' },
      'Technician Service'
    )
  )
);

// Admin Service 프록시
app.use('/api/admin',
  createRequestLogger('ADMIN'),
  createProxyMiddleware(
    createProxyOptions(
      process.env.ADMIN_SERVICE_PORT || 3004,
      { '^/api/admin': '' },
      'Admin Service'
    )
  )
);

// iOS 앱 호환을 위한 직접 엔드포인트 라우팅
// 서비스 관련 엔드포인트
app.use('/api/services', 
  createRequestLogger('SERVICES-DIRECT'),
  createProxyMiddleware(
    createProxyOptions(
      process.env.CONSUMER_SERVICE_PORT || 3002,
      { '^/api/services': '/api/services' },
      'Services API'
    )
  )
);

// 예약 관련 엔드포인트
app.use('/api/reservations',
  createRequestLogger('RESERVATIONS-DIRECT'),
  createProxyMiddleware(
    createProxyOptions(
      process.env.CONSUMER_SERVICE_PORT || 3002,
      { '^/api/reservations': '/api/reservations' },
      'Reservations API'
    )
  )
);

// iOS 앱 호환용 service-categories 경로 추가 - 계층적 카테고리 엔드포인트로 리다이렉트
app.use('/api/service-categories',
  createRequestLogger('SERVICE-CATEGORIES-COMPAT'),
  createProxyMiddleware(
    createProxyOptions(
      process.env.CONSUMER_SERVICE_PORT || 3002,
      { '^/api/service-categories': '/api/services/categories/hierarchical' },
      'Service Categories API'
    )
  )
);

// 프록시 미들웨어 등록 후 로그
console.log('프록시 미들웨어 등록 후');

// 다른 라우트를 위한 본문 파싱은 여기에 배치
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // URL-encoded 데이터 처리 추가

// 메인 라우터 연결
const mainRouter = require('./routes');
app.use('/', mainRouter);

// Global error handler (프록시 외 오류 추적)
app.use((err, req, res, next) => {
  console.error('서버 내부 오류:', err.stack);
  res.status(500).json({
    error: '서버 오류 발생',
    message: err.message,
    timestamp: new Date().toISOString()
  });
});

// Start server
app.listen(PORT, () => {                                                             //서버 실행, 외부 요청 받을 준비
  console.log(`API Gateway running on port ${PORT}`);
  console.log(`API Gateway URL: http://localhost:${PORT}`);
  console.log('For iOS simulator, use http://localhost:3000');
  console.log('Available services:');
  console.log(`- Auth Service: http://localhost:${process.env.AUTH_SERVICE_PORT || 3001}`);
  console.log(`- Consumer Service: http://localhost:${process.env.CONSUMER_SERVICE_PORT || 3002}`);
  console.log(`- Technician Service: http://localhost:${process.env.TECHNICIAN_SERVICE_PORT || 3003}`);
  console.log(`- Admin Service: http://localhost:${process.env.ADMIN_SERVICE_PORT || 3004}`);
});