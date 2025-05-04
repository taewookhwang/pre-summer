// Gateway/index.js with enhanced debugging
const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');
require('dotenv').config();

const app = express();
const PORT = process.env.GATEWAY_PORT || 3000;

// Middleware
app.use(cors());
// body 파싱 미들웨어를 프록시 라우트 뒤로 이동
app.use(morgan('dev')); // 모든 요청에 대한 기본 로그

// Root endpoint for basic connectivity test

// 프록시 미들웨어 등록 전 로그
console.log('프록시 미들웨어 등록 전');

// 프록시 라우트를 먼저 정의 - body 파싱 전에 프록시가 요청을 처리
app.use('/api/auth', (req, res, next) => {
  console.log('==== AUTH REQUEST RECEIVED ====');
  console.log('Timestamp:', new Date().toISOString());
  console.log('Method:', req.method);
  console.log('Full URL:', req.originalUrl); // 전체 경로
  console.log('Path:', req.url); // 미들웨어 경로
  console.log('Headers:', JSON.stringify(req.headers, null, 2));
  // body 파싱 전이므로 req.body 로깅은 제거
  console.log('============================');
  next();
}, createProxyMiddleware({
  target: `http://127.0.0.1:${process.env.AUTH_SERVICE_PORT || 3001}`, // 문자열로 감싸기
  changeOrigin: true,
  pathRewrite: { '^/api/auth': '' }, // Auth Service와 경로 일치
  logLevel: 'debug',
  timeout: 60000, // 60초로 늘림
  proxyTimeout: 120000, // 120초로 늘림
  // buffer 옵션 제거됨
  onProxyReq: (proxyReq, req, res) => {
    console.log(`프록시 요청 시작: ${proxyReq.method} ${proxyReq.path}`); // 문자열로 감싸기
    console.log('프록시 대상:', proxyReq._headers.host);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`프록시 응답 수신: ${proxyRes.statusCode}`);
    console.log('응답 헤더:', JSON.stringify(proxyRes.headers, null, 2));
  },
  onError: (err, req, res) => {
    console.error('프록시 오류 발생:', err.message);
    console.error('상세 오류:', err.stack);
    console.error('요청 URL:', req.originalUrl);
    console.error('요청 Method:', req.method);
    console.error('요청 Headers:', req.headers);
    if (!res.headersSent) {
      res.status(502).json({
        error: 'Auth Service 연결 실패',
        message: err.message,
        code: 'PROXY_ERROR',
        timestamp: new Date().toISOString()
      });
    }
  }
}));

// 프록시 미들웨어 등록 후 로그
console.log('프록시 미들웨어 등록 후');

// 다른 라우트를 위한 본문 파싱은 여기에 배치
app.use(express.json());
app.use(express.urlencoded({ extended: true })); // URL-encoded 데이터 처리 추가

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
app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
  console.log(`API Gateway URL: http://localhost:${PORT}`);
  console.log('For iOS simulator, use http://172.30.1.88:3000 (replace with your Mac\'s IP)');
  console.log(`Auth Service should be running at: http://localhost:${process.env.AUTH_SERVICE_PORT || 3001}`);
});