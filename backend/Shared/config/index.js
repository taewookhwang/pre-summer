/**
 * 중앙화된 설정 관리 모듈
 *
 * 모든 서비스가 일관된 방식으로 환경 변수에 접근할 수 있도록 합니다.
 * 다음 기능을 제공합니다:
 * - 환경 변수 검증 및 기본값 설정
 * - 환경별 설정 파일 지원 (development, test, production)
 * - 로컬 개발 설정 우선 적용 (.env.local)
 * - 필수 환경 변수 검증
 * - 설정값 타입 변환 (string, number, boolean, json, array)
 * - 특정 서비스에 대한 설정 그룹화
 */

const dotenv = require('dotenv');
const path = require('path');
const fs = require('fs');
const logger = require('../logger');

// 환경 변수 로드 함수
const loadEnvFile = (filePath) => {
  try {
    if (fs.existsSync(filePath)) {
      const envConfig = dotenv.parse(fs.readFileSync(filePath));

      // 환경 변수에 로드된 값 설정
      Object.keys(envConfig).forEach((key) => {
        if (!process.env[key]) {
          process.env[key] = envConfig[key];
        }
      });

      return true;
    }
  } catch (error) {
    logger.error(`Error loading environment file ${filePath}:`, error);
  }

  return false;
};

// 환경 변수 로드 순서 (우선순위: 낮음 -> 높음)
// 1. .env.{NODE_ENV} (개발/테스트/운영 환경 공통 설정)
// 2. .env (기본 설정)
// 3. .env.local (로컬 개발자 설정, Git에 커밋되지 않음)
const NODE_ENV = process.env.NODE_ENV || 'development';
const ENV_FILES = [
  path.resolve(process.cwd(), `Infrastructure/.env.${NODE_ENV}`),
  path.resolve(process.cwd(), 'Infrastructure/.env'),
  path.resolve(process.cwd(), 'Infrastructure/.env.local'),
];

// 환경 변수 파일들을 순서대로 로드
let loaded = false;
for (const filePath of ENV_FILES) {
  if (loadEnvFile(filePath)) {
    loaded = true;
    logger.info(`Loaded environment variables from ${filePath}`);
  }
}

if (!loaded) {
  logger.warn('No environment files found. Using system environment variables only.');
}

/**
 * 설정 변수를 타입에 맞게 변환합니다.
 * @param {string} value - 환경 변수 값
 * @param {string} type - 변환할 타입 ('string', 'number', 'boolean', 'json', 'array')
 * @returns {any} 변환된 값
 */
const convertValue = (value, type) => {
  if (value === undefined || value === null) {
    return null;
  }

  switch (type) {
    case 'number':
      return Number(value);
    case 'boolean':
      return value === 'true' || value === '1';
    case 'json':
      try {
        return JSON.parse(value);
      } catch (error) {
        logger.error(`Failed to parse JSON value: ${value}`, error);
        return {};
      }
    case 'array':
      if (!value) return [];
      // 쉼표로 구분된 문자열을 배열로 변환
      return value.split(',').map((item) => item.trim());
    case 'string':
    default:
      return value;
  }
};

/**
 * 환경 변수를 가져옵니다.
 * @param {string} key - 환경 변수 키
 * @param {any} defaultValue - 없을 경우 기본값
 * @param {string} type - 값 타입 ('string', 'number', 'boolean', 'json', 'array')
 * @returns {any} 환경 변수 값
 */
const get = (key, defaultValue = null, type = 'string') => {
  const value = process.env[key];

  if (value === undefined) {
    return defaultValue;
  }

  return convertValue(value, type);
};

/**
 * 필수 환경 변수를 검증합니다.
 * @param {string[]} requiredVars - 필수 환경 변수 키 배열
 * @throws {Error} 필수 환경 변수가 누락된 경우 오류 발생
 */
const validateRequired = (requiredVars) => {
  const missing = [];

  for (const varName of requiredVars) {
    if (!process.env[varName]) {
      missing.push(varName);
    }
  }

  if (missing.length > 0) {
    const errorMessage = `Missing required environment variables: ${missing.join(', ')}`;
    logger.error(errorMessage);
    throw new Error(errorMessage);
  }
};

/**
 * 특정 접두사로 시작하는 모든 환경 변수를 객체로 반환합니다.
 * @param {string} prefix - 환경 변수 접두사 (예: 'AWS_')
 * @returns {Object} 접두사로 시작하는 모든 환경 변수
 */
const getByPrefix = (prefix) => {
  const result = {};
  
  Object.keys(process.env).forEach((key) => {
    if (key.startsWith(prefix)) {
      // 접두사를 제거하고 camelCase로 변환
      const newKey = key.replace(prefix, '').toLowerCase().replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
      result[newKey] = process.env[key];
    }
  });
  
  return result;
};

// 서비스 설정 모음
const config = {
  // 애플리케이션 설정
  app: {
    env: NODE_ENV,
    isDev: NODE_ENV === 'development',
    isProd: NODE_ENV === 'production',
    isTest: NODE_ENV === 'test',
    apiTimeout: get('API_TIMEOUT', 30000, 'number'),
    corsAllowedOrigins: get('CORS_ALLOWED_ORIGINS', '*', 'array'),
  },

  // 서버 설정
  server: {
    gateway: { port: get('GATEWAY_PORT', 3000, 'number') },
    auth: { port: get('AUTH_SERVICE_PORT', 3001, 'number') },
    consumer: { port: get('CONSUMER_SERVICE_PORT', 3002, 'number') },
    technician: { port: get('TECHNICIAN_SERVICE_PORT', 3003, 'number') },
    admin: { port: get('ADMIN_SERVICE_PORT', 3004, 'number') },
    payment: { port: get('PAYMENT_SERVICE_PORT', 3005, 'number') },
    matching: { port: get('MATCHING_SERVICE_PORT', 3006, 'number') },
    chat: { port: get('CHAT_SERVICE_PORT', 3007, 'number') },
    notification: { port: get('NOTIFICATION_SERVICE_PORT', 3008, 'number') },
    review: { port: get('REVIEW_SERVICE_PORT', 3009, 'number') },
    file: { port: get('FILE_SERVICE_PORT', 3010, 'number') },
    cancel: { port: get('CANCEL_SERVICE_PORT', 3011, 'number') },
    realtime: { port: get('REALTIME_SERVICE_PORT', 3012, 'number') },
  },

  // 데이터베이스 설정
  db: {
    host: get('DB_HOST', 'localhost'),
    port: get('DB_PORT', 5432, 'number'),
    username: get('DB_USERNAME', 'postgres'),
    password: get('DB_PASSWORD', ''),
    database: get('DB_NAME', 'homecleaning'),
    dialect: get('DB_DIALECT', 'postgres'),
    // 추가 설정
    pool: {
      max: get('DB_POOL_MAX', 10, 'number'),
      min: get('DB_POOL_MIN', 0, 'number'),
      idle: get('DB_POOL_IDLE', 10000, 'number'),
    },
    logging: get('DB_LOGGING', true, 'boolean'),
    sync: {
      alter: get('DB_SYNC_ALTER', true, 'boolean'),
    },
    // 읽기 전용 복제본 (있는 경우)
    replicaEnabled: get('DB_REPLICA_ENABLED', false, 'boolean'),
    replica: {
      host: get('DB_REPLICA_HOST', ''),
      port: get('DB_REPLICA_PORT', 5432, 'number'),
      username: get('DB_REPLICA_USERNAME', ''),
      password: get('DB_REPLICA_PASSWORD', ''),
    },
  },

  // JWT 인증 설정
  jwt: {
    secret: get('JWT_SECRET', 'default_jwt_secret'),
    algorithm: get('JWT_ALGORITHM', 'HS256'),
    accessExpiresIn: get('JWT_ACCESS_EXPIRES_IN', '1h'),
    refreshExpiresIn: get('JWT_REFRESH_EXPIRES_IN', '7d'),
    issuer: get('JWT_ISSUER', 'homecleaning'),
  },

  // 로깅 설정
  logging: {
    level: get('LOG_LEVEL', 'info'),
    dir: get('LOG_DIR', './logs'),
    maxSize: get('LOG_MAX_SIZE', '10m'),
    maxFiles: get('LOG_MAX_FILES', 7, 'number'),
    timestampFormat: get('LOG_TIMESTAMP_FORMAT', 'YYYY-MM-DD HH:mm:ss.SSS'),
  },

  // 캐시 설정
  cache: {
    enabled: get('CACHE_ENABLED', false, 'boolean'),
    type: get('CACHE_TYPE', 'redis'),
    ttl: get('CACHE_TTL', 300, 'number'),
    redis: {
      host: get('REDIS_HOST', 'localhost'),
      port: get('REDIS_PORT', 6379, 'number'),
      password: get('REDIS_PASSWORD', ''),
      db: get('REDIS_DB', 0, 'number'),
      prefix: get('REDIS_PREFIX', 'hc:'),
    },
  },

  // 외부 서비스 설정
  services: {
    // 결제 설정
    payment: {
      apiUrl: get('PAYMENT_API_URL', 'https://api.tosspayments.com/v1'),
      apiKey: get('PAYMENT_API_KEY', ''),
      apiSecret: get('PAYMENT_API_SECRET', ''),
      webhookSecret: get('PAYMENT_WEBHOOK_SECRET', ''),
      successUrl: get('PAYMENT_SUCCESS_URL', 'http://localhost:3000/payment/success'),
      failUrl: get('PAYMENT_FAIL_URL', 'http://localhost:3000/payment/fail'),
    },
    
    // 파일 스토리지 설정
    storage: {
      type: get('STORAGE_TYPE', 'local'), // 'local' 또는 's3'
      localPath: get('STORAGE_LOCAL_PATH', './uploads'),
      aws: {
        region: get('AWS_REGION', 'ap-northeast-2'),
        s3Bucket: get('AWS_S3_BUCKET', ''),
        accessKeyId: get('AWS_ACCESS_KEY_ID', ''),
        secretAccessKey: get('AWS_SECRET_ACCESS_KEY', ''),
      },
    },
    
    // 푸시 알림 설정
    push: {
      enabled: get('PUSH_ENABLED', true, 'boolean'),
      fcm: {
        projectId: get('FCM_PROJECT_ID', ''),
        privateKey: get('FCM_PRIVATE_KEY', ''),
        clientEmail: get('FCM_CLIENT_EMAIL', ''),
      },
    },
  },

  // 성능 및 확장성 설정 (주로 운영 환경용)
  performance: {
    cluster: {
      enabled: get('NODE_CLUSTER_ENABLED', false, 'boolean'),
      instances: get('NODE_CLUSTER_INSTANCES', 'auto'),
    },
    rateLimit: {
      windowMs: get('RATE_LIMIT_WINDOW_MS', 60000, 'number'),
      max: get('RATE_LIMIT_MAX', 100, 'number'),
    },
    bodyParser: {
      limit: get('BODY_PARSER_LIMIT', '10mb'),
    },
  },

  // 테스트 전용 설정
  test: {
    timeout: get('TEST_TIMEOUT', 5000, 'number'),
    autoCleanup: get('TEST_AUTO_CLEANUP', true, 'boolean'),
    mockExternalApis: get('TEST_MOCK_EXTERNAL_APIS', true, 'boolean'),
  },

  // 유틸리티 함수 노출
  get,
  getByPrefix,
  validateRequired,
};

// 기본 검증
// 운영 환경에서는 주요 설정 항목이 설정되어 있는지 확인
if (NODE_ENV === 'production') {
  validateRequired([
    'JWT_SECRET',
    'DB_PASSWORD',
    'DB_HOST',
  ]);
}

module.exports = config;