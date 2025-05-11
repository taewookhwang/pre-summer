// 카테고리 데이터 시드 스크립트
const { sequelize } = require('./Shared/database');
const logger = require('./Shared/logger');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, 'Infrastructure/.env') });

// 카테고리 모델 불러오기
const seedCategoryData = require('./Services/ConsumerService/src/models/seedData');

// 스크립트 실행 함수
const runSeedScript = async () => {
  try {
    // DB 연결 확인
    await sequelize.authenticate();
    logger.info('Database connection established successfully.');

    // 카테고리 데이터 시드
    await seedCategoryData();

    logger.info('카테고리 데이터 시드 완료');

    // 작업 완료 후 연결 종료
    await sequelize.close();
    process.exit(0);
  } catch (error) {
    logger.error('카테고리 데이터 시드 중 오류 발생:', error);
    process.exit(1);
  }
};

// 스크립트 실행
runSeedScript();
