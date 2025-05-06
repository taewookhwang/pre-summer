const redis = require('redis');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../Infrastructure/.env') });
const logger = require('../logger');

// Redis 클라이언트 설정
const redisClient = redis.createClient({
  url: `redis://${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || 6379}`
});

// Redis 연결 이벤트 처리
redisClient.on('connect', () => {
  logger.info('Redis client connected');
});

redisClient.on('error', (err) => {
  logger.error('Redis client error:', err);
});

// Redis 연결
const connectRedis = async () => {
  try {
    await redisClient.connect();
    logger.info('Redis connection has been established successfully.');
  } catch (error) {
    logger.error('Unable to connect to Redis:', error);
  }
};

// 연결 시작
connectRedis();

// 캐시 읽기
const getCache = async (key) => {
  try {
    const data = await redisClient.get(key);
    
    if (data === null) {
      return null;
    }
    
    try {
      // JSON 데이터 파싱 시도
      return JSON.parse(data);
    } catch (error) {
      logger.warn(`Failed to parse Redis data for key ${key}:`, error);
      return data; // JSON이 아닌 경우 원본 반환
    }
  } catch (err) {
    logger.error(`Redis GET error for key ${key}:`, err);
    throw err;
  }
};

// 캐시 저장
const setCache = async (key, data, expireTime = 3600) => {
  try {
    // 데이터를 문자열로 변환
    const stringValue = typeof data === 'object' ? JSON.stringify(data) : String(data);
    
    const result = await redisClient.set(key, stringValue, {
      EX: expireTime
    });
    
    logger.debug(`Redis cache set for key ${key} with expiry ${expireTime}s`);
    return result;
  } catch (err) {
    logger.error(`Redis SET error for key ${key}:`, err);
    throw err;
  }
};

// 캐시 삭제
const deleteCache = async (key) => {
  try {
    const result = await redisClient.del(key);
    logger.debug(`Redis cache deleted for key ${key}`);
    return result;
  } catch (err) {
    logger.error(`Redis DEL error for key ${key}:`, err);
    throw err;
  }
};

// 캐시 여러 개 삭제 (특정 패턴)
const deleteCachePattern = async (pattern) => {
  try {
    const keys = await redisClient.keys(pattern);
    
    if (keys.length === 0) {
      logger.debug(`No keys found for pattern ${pattern}`);
      return 0;
    }
    
    const count = await redisClient.del(keys);
    logger.debug(`Deleted ${count} keys for pattern ${pattern}`);
    return count;
  } catch (err) {
    logger.error(`Redis pattern delete error for pattern ${pattern}:`, err);
    throw err;
  }
};

module.exports = {
  redisClient,
  getCache,
  setCache,
  deleteCache,
  deleteCachePattern
};