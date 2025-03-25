const redis = require('redis');
require('dotenv').config({ path: '../../Infrastructure/.env' });

const redisClient = redis.createClient({
  url: `redis://${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`
});

redisClient.on('error', (err) => {
  console.error('Redis Client Error', err);
});

const connectRedis = async () => {
  try {
    await redisClient.connect();
    console.log('Redis connection has been established successfully.');
  } catch (error) {
    console.error('Unable to connect to Redis:', error);
  }
};

connectRedis();

module.exports = redisClient;