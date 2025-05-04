const authService = require('../services/authService');

// 회원가입
exports.register = async (req, res) => {
  console.log('1. Register handler called with data:', req.body);
  try {
    console.log('2. Calling authService.registerUser');
    const result = await authService.registerUser(req.body);
    
    console.log('3. Registration successful, sending response');
    res.status(201).json({
      success: true,
      token: result.token,
      refreshToken: result.refreshToken,
      user: result.user
    });
    console.log('4. Response sent');
  } catch (error) {
    console.error('Register error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Server error'
    });
    console.log('5. Error response sent');
  }
};

// 로그인
exports.login = async (req, res) => {
  console.log('1. Login handler called with email:', req.body.email);
  try {
    console.log('2. Calling authService.loginUser');
    const { email, password } = req.body;
    const result = await authService.loginUser(email, password);
    
    console.log('3. Login successful, sending response');
    res.status(200).json({
      success: true,
      token: result.token,
      refreshToken: result.refreshToken,
      user: result.user
    });
    console.log('4. Response sent');
  } catch (error) {
    console.error('Login error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Server error'
    });
    console.log('5. Error response sent');
  }
};

// 토큰 갱신
exports.refreshToken = async (req, res) => {
  console.log('1. RefreshToken handler called');
  try {
    console.log('2. Calling authService.refreshUserToken');
    const { refreshToken } = req.body;
    const result = await authService.refreshUserToken(refreshToken);
    
    console.log('3. Token refresh successful, sending response');
    res.status(200).json({
      success: true,
      token: result.token
    });
    console.log('4. Response sent');
  } catch (error) {
    console.error('Refresh token error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Server error'
    });
    console.log('5. Error response sent');
  }
};

// 현재 사용자 정보 조회
exports.getCurrentUser = async (req, res) => {
  console.log('1. GetCurrentUser handler called for user ID:', req.user?.id);
  try {
    console.log('2. Calling authService.getUserById');
    // req.user는 authMiddleware.protect에서 설정됨
    const user = await authService.getUserById(req.user.id);
    
    console.log('3. User found, sending response');
    res.status(200).json({
      success: true,
      data: user
    });
    console.log('4. Response sent');
  } catch (error) {
    console.error('Get current user error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Server error'
    });
    console.log('5. Error response sent');
  }
};