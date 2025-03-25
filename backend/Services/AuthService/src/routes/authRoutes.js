const express = require('express');
const { register, login, refreshToken, getCurrentUser } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// 공개 라우트
router.post('/register', register);
router.post('/login', login);
router.post('/refresh', refreshToken);

// 보호된 라우트 (인증 필요)
router.get('/me', protect, getCurrentUser);

module.exports = router;