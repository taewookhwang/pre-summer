// 데이터베이스 초기화 스크립트
const { syncModels, seedData } = require('./Shared/database/ModelsSync');
const logger = require('./Shared/logger');

// 명령줄 인자 확인: force 옵션 (테이블 재생성 여부)
const force = process.argv.includes('--force');

// 모델 동기화 및 초기 데이터 생성
const initializeDatabase = async () => {
  try {
    await syncModels(force);
    logger.info('데이터베이스 초기화가 완료되었습니다.');
    process.exit(0);
  } catch (error) {
    logger.error('데이터베이스 초기화 중 오류 발생:', error);
    process.exit(1);
  }
};

// 실행
initializeDatabase();