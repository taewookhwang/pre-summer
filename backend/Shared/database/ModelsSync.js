const { sequelize } = require('./index');
const path = require('path');
const fs = require('fs');
const logger = require('../logger');

// 서비스별 모델 로드
const loadModels = () => {
  // 모델 경로 설정
  const servicesFolders = [
    '../Services/AuthService/src/models',
    '../Services/ConsumerService/src/models',
    '../Services/TechnicianService/src/models',
    '../Services/AdminService/src/models'
  ];

  // 모델 로드 및 관계 설정
  servicesFolders.forEach(folderPath => {
    try {
      const fullPath = path.join(__dirname, folderPath);
      if (fs.existsSync(fullPath)) {
        logger.info(`로딩 모델 폴더: ${folderPath}`);
        fs.readdirSync(fullPath)
          .filter(file => file.endsWith('.js') && file !== 'index.js')
          .forEach(file => {
            try {
              require(path.join(fullPath, file));
              logger.info(`로드된 모델: ${file}`);
            } catch (error) {
              logger.error(`모델 로드 중 오류 발생 ${file}:`, error);
            }
          });
      }
    } catch (error) {
      logger.error(`모델 폴더 로드 중 오류 발생 ${folderPath}:`, error);
    }
  });
};

// 모델 동기화
const syncModels = async (force = false) => {
  try {
    // 모델 로드
    loadModels();

    // 모델 동기화
    logger.info(`모델 동기화 시작 (force=${force})`);
    await sequelize.sync({ force }); // force: true는 테이블을 재생성합니다
    logger.info('모델 동기화 완료');

    // 초기 데이터 생성 후 데이터베이스 연결 종료
    await seedData();
    logger.info('초기 데이터 생성 완료');
    await sequelize.close();
    logger.info('데이터베이스 연결 종료');
  } catch (error) {
    logger.error('모델 동기화 중 오류 발생:', error);
  }
};

// 초기 데이터 생성
const seedData = async () => {
  try {
    // User 모델 가져오기
    const User = sequelize.models.User;
    if (!User) {
      logger.error('User 모델을 찾을 수 없습니다');
      return;
    }

    // 관리자 계정 생성 (이미 있는지 확인 후)
    const adminExists = await User.findOne({ where: { email: 'admin@example.com' } });
    if (!adminExists) {
      await User.create({
        email: 'admin@example.com',
        password_hash: '$2b$10$Xgs26XuNnAr7lkGSthD6NObAkNuA3rCexE0GKqHyxr.iKySO7Jlzu', // "password123"
        role: 'admin',
        name: '관리자',
        phone: '010-1234-5678',
        address: '서울시 강남구'
      });
      logger.info('관리자 계정 생성 완료');
    }

    // 소비자 계정 생성
    const consumerExists = await User.findOne({ where: { email: 'consumer@example.com' } });
    if (!consumerExists) {
      await User.create({
        email: 'consumer@example.com',
        password_hash: '$2b$10$Xgs26XuNnAr7lkGSthD6NObAkNuA3rCexE0GKqHyxr.iKySO7Jlzu', // "password123"
        role: 'consumer',
        name: '홍길동',
        phone: '010-1111-2222',
        address: '서울시 서초구'
      });
      logger.info('소비자 계정 생성 완료');
    }

    // 기술자 계정 생성
    const technicianExists = await User.findOne({ where: { email: 'technician@example.com' } });
    if (!technicianExists) {
      await User.create({
        email: 'technician@example.com',
        password_hash: '$2b$10$Xgs26XuNnAr7lkGSthD6NObAkNuA3rCexE0GKqHyxr.iKySO7Jlzu', // "password123"
        role: 'technician',
        name: '김청소',
        phone: '010-3333-4444',
        address: '서울시 용산구'
      });
      logger.info('기술자 계정 생성 완료');
    }

    // 서비스 모델 가져오기
    const Service = sequelize.models.Service;
    if (!Service) {
      logger.error('Service 모델을 찾을 수 없습니다');
      return;
    }

    // 서비스 데이터 생성
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

    // 서비스 데이터 생성 (중복 체크 후)
    for (const service of services) {
      const serviceExists = await Service.findOne({ where: { name: service.name } });
      if (!serviceExists) {
        await Service.create(service);
        logger.info(`서비스 생성 완료: ${service.name}`);
      }
    }
  } catch (error) {
    logger.error('초기 데이터 생성 중 오류 발생:', error);
  }
};

// 명령줄에서 직접 실행할 때 사용
if (require.main === module) {
  // 커맨드라인 인자 확인: force 옵션 (테이블 재생성 여부)
  const force = process.argv.includes('--force');
  syncModels(force);
}

module.exports = {
  syncModels,
  seedData
};