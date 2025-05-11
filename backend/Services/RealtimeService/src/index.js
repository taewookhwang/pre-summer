const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const logger = require('../../../Shared/logger');

// 환경 변수 설정
const PORT = process.env.REALTIME_SERVICE_PORT || 3005;
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

// Express 앱 초기화
const app = express();
app.use(cors());
app.use(express.json());

// HTTP 서버 생성
const server = http.createServer(app);

// Socket.IO 서버 생성
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// 활성 연결 관리
const activeConnections = new Map();

// 인증 미들웨어
io.use((socket, next) => {
  try {
    const token = socket.handshake.query.token;

    if (!token) {
      return next(new Error('Authentication error: No token provided'));
    }

    // 토큰 검증
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
      if (err) {
        return next(new Error('Authentication error: Invalid token'));
      }

      // 사용자 정보 저장
      socket.user = decoded;

      logger.info(`User authenticated: ${decoded.id} (${decoded.role})`);
      next();
    });
  } catch (error) {
    logger.error('Socket authentication error:', error);
    next(new Error('Authentication error'));
  }
});

// 연결 이벤트 핸들링
io.on('connection', (socket) => {
  const userId = socket.user.id;
  const userRole = socket.user.role;

  logger.info(`New connection: User ${userId} (${userRole})`);

  // 사용자 정보 저장
  activeConnections.set(socket.id, {
    userId,
    userRole,
    socket,
  });

  // 연결 성공 이벤트 발송
  socket.emit('connect', {
    user_id: userId,
    timestamp: new Date().toISOString(),
    session_id: socket.id,
  });

  // 예약 채널 구독
  socket.on('join_reservation', async (data) => {
    try {
      const { reservation_id } = data;

      if (!reservation_id) {
        return socket.emit('error', {
          code: '1002',
          message: 'Invalid message format',
          details: 'reservation_id is required',
        });
      }

      logger.info(`User ${userId} joining reservation channel: ${reservation_id}`);

      // 채널 구독 (socket.io의 room 기능 사용)
      socket.join(`reservation:${reservation_id}`);

      socket.emit('join_success', {
        channel: `reservation:${reservation_id}`,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Error joining reservation channel:', error);
      socket.emit('error', {
        code: '1006',
        message: 'Failed to join reservation channel',
        details: error.message,
      });
    }
  });

  // 사용자 채널 구독
  socket.on('join_user', (data) => {
    try {
      const { user_id } = data;

      if (!user_id) {
        return socket.emit('error', {
          code: '1002',
          message: 'Invalid message format',
          details: 'user_id is required',
        });
      }

      // 자신의 채널만 구독 가능
      if (userId !== parseInt(user_id) && userRole !== 'admin') {
        return socket.emit('error', {
          code: '1005',
          message: 'Permission denied',
          details: 'You can only join your own user channel',
        });
      }

      logger.info(`User ${userId} joining user channel: ${user_id}`);

      // 채널 구독
      socket.join(`user:${user_id}`);

      socket.emit('join_success', {
        channel: `user:${user_id}`,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      logger.error('Error joining user channel:', error);
      socket.emit('error', {
        code: '1006',
        message: 'Failed to join user channel',
        details: error.message,
      });
    }
  });

  // 위치 업데이트 이벤트
  socket.on('location_update', (data) => {
    try {
      const { reservation_id, latitude, longitude } = data;

      if (!reservation_id || latitude === undefined || longitude === undefined) {
        return socket.emit('error', {
          code: '1002',
          message: 'Invalid message format',
          details: 'reservation_id, latitude, and longitude are required',
        });
      }

      // 위치 데이터에 타임스탬프 추가
      const locationData = {
        ...data,
        user_id: userId,
        user_type: userRole,
        timestamp: data.timestamp || new Date().toISOString(),
      };

      logger.info(
        `Location update from ${userId} for reservation ${reservation_id}: ${latitude}, ${longitude}`,
      );

      // 예약 채널에 위치 업데이트 브로드캐스트
      io.to(`reservation:${reservation_id}`).emit('location_update', locationData);

      // TODO: 위치 데이터 저장 및 ETA 계산
    } catch (error) {
      logger.error('Error processing location update:', error);
      socket.emit('error', {
        code: '1006',
        message: 'Failed to process location update',
        details: error.message,
      });
    }
  });

  // 채팅 메시지 이벤트
  socket.on('chat_message', (data) => {
    try {
      const { reservation_id, content, type } = data;

      if (!reservation_id || !content) {
        return socket.emit('error', {
          code: '1002',
          message: 'Invalid message format',
          details: 'reservation_id and content are required',
        });
      }

      // 채팅 메시지 데이터 준비
      const messageData = {
        message_id: generateId(),
        reservation_id,
        sender_id: userId,
        sender_type: userRole,
        sender_name: socket.user.name || 'User',
        content,
        type: type || 'text',
        image_url: data.image_url,
        location: data.location,
        read: false,
        timestamp: data.timestamp || new Date().toISOString(),
      };

      logger.info(
        `Chat message from ${userId} for reservation ${reservation_id}: ${content.substring(0, 30)}...`,
      );

      // 예약 채널에 채팅 메시지 브로드캐스트
      io.to(`reservation:${reservation_id}`).emit('chat_message', messageData);

      // TODO: 채팅 메시지 저장
    } catch (error) {
      logger.error('Error processing chat message:', error);
      socket.emit('error', {
        code: '1006',
        message: 'Failed to process chat message',
        details: error.message,
      });
    }
  });

  // 메시지 읽음 상태 이벤트
  socket.on('message_read', (data) => {
    try {
      const { reservation_id, message_ids } = data;

      if (!reservation_id || !message_ids || !Array.isArray(message_ids)) {
        return socket.emit('error', {
          code: '1002',
          message: 'Invalid message format',
          details: 'reservation_id and message_ids array are required',
        });
      }

      // 읽음 상태 데이터 준비
      const readData = {
        reservation_id,
        message_ids,
        reader_id: userId,
        reader_type: userRole,
        timestamp: data.timestamp || new Date().toISOString(),
      };

      logger.info(
        `Message read status from ${userId} for reservation ${reservation_id}: ${message_ids.length} messages`,
      );

      // 예약 채널에 읽음 상태 브로드캐스트
      io.to(`reservation:${reservation_id}`).emit('message_read', readData);

      // TODO: 메시지 읽음 상태 업데이트
    } catch (error) {
      logger.error('Error processing message read status:', error);
      socket.emit('error', {
        code: '1006',
        message: 'Failed to process message read status',
        details: error.message,
      });
    }
  });

  // 타이핑 인디케이터 이벤트
  socket.on('typing_indicator', (data) => {
    try {
      const { reservation_id, is_typing } = data;

      if (!reservation_id || is_typing === undefined) {
        return socket.emit('error', {
          code: '1002',
          message: 'Invalid message format',
          details: 'reservation_id and is_typing are required',
        });
      }

      // 타이핑 인디케이터 데이터 준비
      const typingData = {
        reservation_id,
        user_id: userId,
        user_type: userRole,
        is_typing,
        timestamp: data.timestamp || new Date().toISOString(),
      };

      // 예약 채널에 타이핑 인디케이터 브로드캐스트
      io.to(`reservation:${reservation_id}`).emit('typing_indicator', typingData);
    } catch (error) {
      logger.error('Error processing typing indicator:', error);
      socket.emit('error', {
        code: '1006',
        message: 'Failed to process typing indicator',
        details: error.message,
      });
    }
  });

  // 연결 종료 이벤트
  socket.on('disconnect', () => {
    logger.info(`User disconnected: ${userId}`);

    // 연결 정보 삭제
    activeConnections.delete(socket.id);

    // 연결 종료 이벤트 발송 (다른 연결된 클라이언트에게)
    // socket.broadcast.emit('user_disconnected', { user_id: userId });
  });
});

// 루트 라우트
app.get('/', (req, res) => {
  res.status(200).send({
    message: 'Welcome to Realtime Service API',
  });
});

// 연결 통계 API
app.get('/api/stats', (req, res) => {
  res.status(200).json({
    success: true,
    stats: {
      connections: activeConnections.size,
      timestamp: new Date().toISOString(),
    },
  });
});

// 이벤트 발송 API (내부 서비스에서 호출)
app.post('/api/events', (req, res) => {
  try {
    const { event_type, target_type, target_id, data } = req.body;

    if (!event_type || !target_type || !target_id || !data) {
      return res.status(400).json({
        success: false,
        error: {
          message: 'Invalid request',
          details: 'event_type, target_type, target_id, and data are required',
        },
      });
    }

    // 타겟에 따라 이벤트 발송
    if (target_type === 'reservation') {
      io.to(`reservation:${target_id}`).emit(event_type, data);
      logger.info(`Event ${event_type} emitted to reservation ${target_id}`);
    } else if (target_type === 'user') {
      io.to(`user:${target_id}`).emit(event_type, data);
      logger.info(`Event ${event_type} emitted to user ${target_id}`);
    } else {
      return res.status(400).json({
        success: false,
        error: {
          message: 'Invalid target type',
          details: 'target_type must be reservation or user',
        },
      });
    }

    res.status(200).json({
      success: true,
      message: 'Event emitted successfully',
    });
  } catch (error) {
    logger.error('Error emitting event:', error);
    res.status(500).json({
      success: false,
      error: {
        message: 'Failed to emit event',
        details: error.message,
      },
    });
  }
});

// 서버 시작
server.listen(PORT, () => {
  logger.info(`Realtime Service running on port ${PORT}`);
});

/**
 * 고유 ID 생성
 * @returns {String} UUID
 */
function generateId() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}
