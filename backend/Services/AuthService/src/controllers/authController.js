const authService = require('../services/authService');

// 회원가입
exports.register = async (req, res) => {
  try {
    const result = await authService.registerUser(req.body);
    
    res.status(201).json({
      success: true,
      token: result.token,
      refreshToken: result.refreshToken,
      user: result.user
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Server error'
    });
  }
};

// 로그인
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await authService.loginUser(email, password);
    
    res.status(200).json({
      success: true,
      token: result.token,
      refreshToken: result.refreshToken,
      user: result.user
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Server error'
    });
  }
};

// 토큰 갱신
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    const result = await authService.refreshUserToken(refreshToken);
    
    res.status(200).json({
      success: true,
      token: result.token
    });
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Server error'
    });
  }
};

// 현재 사용자 정보 조회
exports.getCurrentUser = async (req, res) => {
  try {
    // req.user는 authMiddleware.protect에서 설정됨
    const user = await authService.getUserById(req.user.id);
    
    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    console.error('Get current user error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Server error'
    });
  }
};