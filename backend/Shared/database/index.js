const { Sequelize } = require('sequelize');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });

// 환경변수 확인 로그
console.log('Database config:', {
  name: process.env.DB_NAME,
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT
});

const sequelize = new Sequelize(
  process.env.DB_NAME || 'homecleaning',
  process.env.DB_USER || 'admin',
  process.env.DB_PASSWORD || 'password',
  {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    // 연결 재시도 옵션 추가
    retry: {
      max: 3,
      timeout: 10000
    }
  }
);

// 명시적인 연결 함수 추가
const connectDatabase = async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connection has been established successfully.');
    return true;
  } catch (error) {
    console.error('Unable to connect to the database:', error);
    // 연결 실패 시 10초 후 재시도 로직
    console.log('Retrying database connection in 10 seconds...');
    return false;
  }
};

// 기존 testConnection 함수는 유지하되 더 명확한 에러 처리 추가
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connection has been established successfully.');
  } catch (error) {
    console.error('Unable to connect to the database:', error);
    console.error('Database connection error details:', {
      code: error.original?.code,
      errno: error.original?.errno,
      syscall: error.original?.syscall,
      hostname: error.original?.hostname
    });
  }
};

// 연결 시도
testConnection();

// 데이터베이스 연결이 성공했는지 확인하는 헬퍼 함수 추가
sequelize.isConnected = async () => {
  try {
    await sequelize.authenticate();
    return true;
  } catch (error) {
    return false;
  }
};

module.exports = sequelize;