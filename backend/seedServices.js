// 서비스 데이터 시드 스크립트
const { sequelize } = require('./Shared/database');
const logger = require('./Shared/logger');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, 'Infrastructure/.env') });

// 서비스 모델 불러오기
const Service = require('./Services/ConsumerService/src/models/Service');

// 서비스 데이터 추가
const seedServices = async () => {
  try {
    // DB 연결 확인
    await sequelize.authenticate();
    logger.info('Database connection established successfully.');

    // 서비스 데이터
    const services = [
      {
        name: '일반 청소',
        description: '집이나 사무실의 기본적인 청소 서비스',
        price: 50000,
        duration: 120, // 분 단위
        category: '일반',
        isActive: true
      },
      {
        name: '딥 클리닝',
        description: '깊이 있는 청소로 숨겨진 먼지와 오염까지 제거',
        price: 100000,
        duration: 240,
        category: '특수',
        isActive: true
      },
      {
        name: '입주 청소',
        description: '새로운 집으로 이사 전 완벽한 상태로 준비',
        price: 150000,
        duration: 300,
        category: '특수',
        isActive: true
      },
      {
        name: '사무실 청소',
        description: '사무실 환경을 깨끗하고 위생적으로 유지',
        price: 80000,
        duration: 180,
        category: '사무실',
        isActive: true
      }
    ];

    // 서비스 데이터 생성
    for (const serviceData of services) {
      const [service, created] = await Service.findOrCreate({
        where: { name: serviceData.name },
        defaults: serviceData
      });

      if (created) {
        logger.info(`서비스 생성 완료: ${service.name}`);
      } else {
        logger.info(`이미 존재하는 서비스: ${service.name}`);
      }
    }

    logger.info('서비스 데이터 추가 완료');
    await sequelize.close();
  } catch (error) {
    logger.error('서비스 데이터 추가 중 오류 발생:', error);
  }
};

// 스크립트 실행
seedServices();