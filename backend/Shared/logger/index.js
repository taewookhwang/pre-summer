/**
 * 통합 로깅 시스템
 *
 * winston 기반 로깅 시스템으로 모든 서비스가 일관된 로그 형식을 사용하도록 합니다.
 * 다음 기능을 제공합니다:
 * - 로그 레벨 제어 (debug, info, warn, error)
 * - 타임스탬프 및 요청 ID 추적
 * - 콘솔 및 파일 로깅 (개발/운영 환경별)
 * - 에러 스택 트레이스 포맷팅
 * - 서비스 이름 자동 추출 및 표시 
 * - 구조화된 JSON 로깅
 * - 로그 컨텍스트 유지
 */
const winston = require('winston');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
require('dotenv').config({ path: path.join(__dirname, '../../Infrastructure/.env') });

// 서비스명 추출 (로그에 표시될 기본 서비스명)
let serviceName = 'backend';
try {
  const packageJson = require(path.join(process.cwd(), 'package.json'));
  serviceName = packageJson.name || 'backend';
} catch (err) {
  // package.json을 찾을 수 없는 경우 기본값 사용
}

// 로그 레벨 설정 및 설명
const LOG_LEVELS = {
  error: 0, // 치명적인 오류 (서비스가 제대로 작동하지 않음)
  warn: 1,  // 주의해야 할 문제 (정상 작동하지만 잠재적 문제)
  info: 2,  // 중요한 작업 정보 (서비스 시작/종료, 작업 완료 등)
  http: 3,  // HTTP 요청 정보
  debug: 4, // 디버깅용 상세 정보
};

// 환경별 로그 레벨 기본값
const getDefaultLogLevel = () => {
  const env = process.env.NODE_ENV || 'development';
  switch (env) {
    case 'production':
      return 'info';  // 운영 환경: info 이상만 로깅
    case 'test':
      return 'warn';  // 테스트 환경: warning 이상만 로깅
    default:
      return 'debug'; // 개발 환경: 모든 로그 레벨 출력
  }
};

// 로그 레벨 설정 (환경 변수에서 가져오거나 기본값 사용)
const logLevel = process.env.LOG_LEVEL || getDefaultLogLevel();

// 로그 포맷: 구조화된 정보 포맷 (JSON)
const structuredFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json(),
);

// 로그 포맷: 콘솔 출력용 사람이 읽기 쉬운 포맷
const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.printf((info) => {
    // 메시지가 객체인 경우 JSON으로 변환
    const message =
      typeof info.message === 'object' ? JSON.stringify(info.message, null, 2) : info.message;

    // 요청 ID가 있다면 포함
    const reqId = info.requestId ? `[${info.requestId}] ` : '';
    // 서비스 이름 포함
    const service = info.service ? `[${info.service}] ` : '';
    // 코드 위치 정보
    const codeInfo = info.filename && info.line ? `[${info.filename}:${info.line}] ` : '';
    // 사용자 정보
    const user = info.userId ? `[user:${info.userId}] ` : '';
    
    // 스택 트레이스가 있다면 메시지 뒤에 추가
    const stack = info.stack ? `\n${info.stack}` : '';

    return `${info.timestamp} ${info.level}: ${service}${reqId}${user}${codeInfo}${message}${stack}`;
  }),
);

// 로그 저장 디렉토리 확인 및 생성
const fs = require('fs');
const logDir = path.join(__dirname, '../../logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir);
}

// 날짜별 로그 파일명 생성 함수
const getLogFileName = (level) => {
  const date = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
  return path.join(logDir, `${date}-${level}.log`);
};

// Winston 로거 설정
const logger = winston.createLogger({
  levels: LOG_LEVELS,
  level: logLevel,
  defaultMeta: {
    service: serviceName,
    environment: process.env.NODE_ENV || 'development',
  },
  transports: [
    // 콘솔 출력
    new winston.transports.Console({
      format: consoleFormat,
    }),
    
    // 모든 로그를 저장하는 파일
    new winston.transports.File({
      filename: path.join(logDir, 'combined.log'),
      format: structuredFormat,
    }),
    
    // 날짜별 에러 로그 파일
    new winston.transports.File({
      filename: getLogFileName('error'),
      level: 'error',
      format: structuredFormat,
    }),
    
    // 날짜별 종합 로그 파일
    new winston.transports.File({
      filename: getLogFileName('combined'),
      format: structuredFormat,
    }),
  ],
  exitOnError: false, // 로깅 오류로 인한 앱 종료 방지
});

/**
 * 호출 위치 정보를 추출하는 함수
 * 로그가 어디서 호출되었는지 파일명과 라인 번호를 추출합니다.
 */
const getCallerInfo = () => {
  const error = new Error();
  const stack = error.stack.split('\n');
  
  // logger 함수를 호출한 위치를 찾습니다 (일반적으로 3번째 라인)
  if (stack.length >= 4) {
    // 예: "at Object.<anonymous> (/path/to/file.js:10:5)"
    const callerLine = stack[3];
    const match = callerLine.match(/\((.+):(\d+):(\d+)\)/) || 
                 callerLine.match(/at\s+(.+):(\d+):(\d+)/);
    
    if (match) {
      const [, filePath, line, column] = match;
      const filename = path.basename(filePath);
      return { filename, line, column };
    }
  }
  
  return { filename: 'unknown', line: '?', column: '?' };
};

/**
 * 요청 로깅을 위한 미들웨어
 * Express 애플리케이션에서 요청/응답 로깅에 사용합니다.
 * 모든 요청에 고유 ID를 부여해 추적할 수 있도록 합니다.
 */
const requestLogger = (req, res, next) => {
  // 요청 ID 생성 및 설정
  const requestId = req.headers['x-request-id'] || uuidv4();
  req.requestId = requestId;
  
  // 응답 헤더에도 요청 ID 포함
  res.setHeader('X-Request-ID', requestId);

  // 로그 메타데이터에 요청 ID 추가
  const meta = { 
    requestId,
    userId: req.user?.id, // 인증된 사용자 ID (있는 경우)
    ip: req.ip,
    method: req.method,
    url: req.originalUrl || req.url,
    userAgent: req.get('User-Agent'),
  };

  // 요청 시작 로깅
  logger.http(`Request started: ${req.method} ${req.originalUrl || req.url}`, meta);

  // 응답 시간 측정을 위한 시작 시간
  const startHrTime = process.hrtime();

  // 응답 완료 이벤트에 로깅 추가
  res.on('finish', () => {
    // 응답 시간 계산
    const elapsedHrTime = process.hrtime(startHrTime);
    const responseTimeMs = (elapsedHrTime[0] * 1000 + elapsedHrTime[1] / 1000000).toFixed(3);
    
    // 상태 코드에 따라 로그 레벨 결정
    const level = res.statusCode >= 500 ? 'error' : 
                 res.statusCode >= 400 ? 'warn' : 
                 'http';
    
    // 응답 완료 로그
    logger[level](
      `Request completed: ${req.method} ${req.originalUrl || req.url} ${res.statusCode} (${responseTimeMs}ms)`,
      {
        ...meta,
        statusCode: res.statusCode,
        responseTime: responseTimeMs,
        contentLength: res.getHeader('content-length'),
      }
    );
  });

  // 요청 처리 중 오류 발생 시
  res.on('error', (error) => {
    logger.error(`Request error: ${req.method} ${req.originalUrl || req.url}`, {
      ...meta,
      error: error.message,
      stack: error.stack,
    });
  });

  // 다음 미들웨어로 진행
  next();
};

/**
 * 확장된 로거 객체
 * - 기본 로깅 메서드 (debug, info, warn, error)
 * - 호출 위치 정보 자동 추가
 * - 요청 컨텍스트 로깅 기능
 * - 요청 로깅 미들웨어
 */
const enhancedLogger = {
  // 기본 로그 메서드
  debug: (message, meta = {}) => {
    const callerInfo = getCallerInfo();
    logger.debug(message, { ...callerInfo, ...meta });
  },
  
  info: (message, meta = {}) => {
    const callerInfo = getCallerInfo();
    logger.info(message, { ...callerInfo, ...meta });
  },
  
  http: (message, meta = {}) => {
    const callerInfo = getCallerInfo();
    logger.http(message, { ...callerInfo, ...meta });
  },
  
  warn: (message, meta = {}) => {
    const callerInfo = getCallerInfo();
    logger.warn(message, { ...callerInfo, ...meta });
  },
  
  error: (message, meta = {}) => {
    const callerInfo = getCallerInfo();
    // 에러 객체가 전달된 경우
    if (message instanceof Error) {
      return logger.error(message.message, { 
        ...callerInfo, 
        ...meta, 
        stack: message.stack,
        code: message.code,
      });
    }
    logger.error(message, { ...callerInfo, ...meta });
  },

  // 요청 컨텍스트 로깅 (요청 ID 포함)
  request: (req) => ({
    debug: (message, meta = {}) => {
      const callerInfo = getCallerInfo();
      logger.debug(message, { 
        ...callerInfo, 
        ...meta, 
        requestId: req.requestId,
        userId: req.user?.id,
      });
    },
    info: (message, meta = {}) => {
      const callerInfo = getCallerInfo();
      logger.info(message, { 
        ...callerInfo, 
        ...meta, 
        requestId: req.requestId,
        userId: req.user?.id,
      });
    },
    http: (message, meta = {}) => {
      const callerInfo = getCallerInfo();
      logger.http(message, { 
        ...callerInfo, 
        ...meta, 
        requestId: req.requestId,
        userId: req.user?.id,
      });
    },
    warn: (message, meta = {}) => {
      const callerInfo = getCallerInfo();
      logger.warn(message, { 
        ...callerInfo, 
        ...meta, 
        requestId: req.requestId,
        userId: req.user?.id,
      });
    },
    error: (message, meta = {}) => {
      const callerInfo = getCallerInfo();
      // 에러 객체가 전달된 경우
      if (message instanceof Error) {
        return logger.error(message.message, { 
          ...callerInfo, 
          ...meta, 
          requestId: req.requestId,
          userId: req.user?.id,
          stack: message.stack,
          code: message.code,
        });
      }
      logger.error(message, { 
        ...callerInfo, 
        ...meta, 
        requestId: req.requestId,
        userId: req.user?.id,
      });
    },
  }),

  // 요청 로깅 미들웨어
  middleware: requestLogger,
};

module.exports = enhancedLogger;