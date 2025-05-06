const authService = require('../services/authService');

// 회원가입
exports.register = async (req, res) => {
  console.log('1. Register handler called with data:', req.body);
  try {
    console.log('2. Calling authService.registerUser');
    const result = await authService.registerUser(req.body);
    
    // user 객체 snake_case로 변환
    const formattedUser = {
      id: result.user.id,
      email: result.user.email,
      role: result.user.role,
      name: result.user.name,
      phone: result.user.phone,
      address: result.user.address,
      created_at: result.user.created_at
    };
    
    console.log('3. Registration successful, sending response');
    res.status(201).json({
      success: true,
      token: result.token,
      refresh_token: result.refreshToken,
      user: formattedUser
    });
    console.log('4. Response sent');
  } catch (error) {
    console.error('Register error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: {
        message: error.message || 'Server error',
        details: error.message
      }
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
    
    // user 객체 snake_case로 변환
    const formattedUser = {
      id: result.user.id,
      email: result.user.email,
      role: result.user.role,
      name: result.user.name,
      phone: result.user.phone,
      address: result.user.address,
      created_at: result.user.created_at
    };
    
    console.log('3. Login successful, sending response');
    res.status(200).json({
      success: true,
      token: result.token,
      refresh_token: result.refreshToken,
      user: formattedUser
    });
    console.log('4. Response sent');
  } catch (error) {
    console.error('Login error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: {
        message: error.message || 'Server error',
        details: error.message
      }
    });
    console.log('5. Error response sent');
  }
};

// 토큰 갱신
exports.refreshToken = async (req, res) => {
  console.log('1. RefreshToken handler called');
  try {
    console.log('2. Calling authService.refreshUserToken');
    // 클라이언트에서는 snake_case로 받지만 서비스에는 원래 이름으로 전달
    const { refresh_token } = req.body;  // snake_case 필드명 사용
    const result = await authService.refreshUserToken(refresh_token);
    
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
      error: {
        message: error.message || 'Server error',
        details: error.message
      }
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
    
    // snake_case로 변환
    const formattedUser = {
      id: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
      phone: user.phone,
      address: user.address,
      created_at: user.created_at
    };
    
    console.log('3. User found, sending response');
    res.status(200).json({
      success: true,
      user: formattedUser  // 'data' 대신 'user' 필드 사용
    });
    console.log('4. Response sent');
  } catch (error) {
    console.error('Get current user error:', error);
    res.status(error.statusCode || 500).json({
      success: false,
      error: {
        message: error.message || 'Server error',
        details: error.message
      }
    });
    console.log('5. Error response sent');
  }
};