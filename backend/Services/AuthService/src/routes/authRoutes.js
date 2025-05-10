const express = require('express');
const authController = require('../controllers/authController');
const { authenticateUser, restrictTo } = require('../middleware/authMiddleware');

const router = express.Router();

// 공개 라우트
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/refresh', authController.refreshToken);

// 보호된 라우트 (인증 필요)
router.get('/me', authenticateUser, authController.getCurrentUser);

module.exports = router;