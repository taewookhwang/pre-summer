const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config({ path: '../../Infrastructure/.env' });

const app = express();

// 미들웨어
app.use(cors());
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 프록시 설정 (실제 마이크로서비스로 라우팅)
app.use('/api/auth', (req, res, next) => {
  // AuthService로 프록시 (개발 단계에서는 직접 라우팅)
  const url = `http://localhost:${process.env.AUTH_SERVICE_PORT || 3001}/api/auth${req.url}`;
  console.log(`Proxying to: ${url}`);
  // 여기서는 간단한 프록시만 보여주지만, 실제로는 http-proxy-middleware 등 사용 권장
  next();
});

// 기본 라우트
app.get('/', (req, res) => {
  res.json({ message: 'API Gateway is running' });
});

// 서버 시작
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});