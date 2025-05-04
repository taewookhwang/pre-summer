const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
//const bodyParser = require('body-parser'); // 별도의 body-parser 사용
require('dotenv').config({ path: '../../../Infrastructure/.env' });

// 데이터베이스 연결
require('../../../Shared/database');

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
    console.log('Request body received:', req.body);
  }
  next();
});

// 라우트
app.use('/', authRoutes);

// 기본 라우트
app.get('/', (req, res) => {
  res.json({ message: 'Auth Service is running' });
});

// 에러 핸들링 미들웨어
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.statusCode || 500).json({
    success: false,
    error: err.message || 'Server error'
  });
});

// 서버 시작
const PORT = process.env.AUTH_SERVICE_PORT || 3001;
app.listen(PORT, () => {
  console.log(`Auth Service running on port ${PORT}`);
});