const { sequelize } = require('../../../../Shared/database');
const logger = require('../../../../Shared/logger');
const { Category, SubCategory, Service, ServiceOption, CustomField } = require('./index');

// 초기 데이터 생성
const seedCategoryData = async () => {
  try {
    // 카테고리 데이터
    const categories = [
      {
        id: 'cleaning',
        name: '청소',
        iconUrl: 'https://example.com/icons/cleaning.png'
      },
      {
        id: 'laundry',
        name: '세탁',
        iconUrl: 'https://example.com/icons/laundry.png'
      },
      {
        id: 'kitchen',
        name: '주방',
        iconUrl: 'https://example.com/icons/kitchen.png'
      }
    ];

    // 서브카테고리 데이터
    const subcategories = [
      {
        id: 'regular_cleaning',
        name: '일반 청소',
        parentId: 'cleaning'
      },
      {
        id: 'special_cleaning',
        name: '특수 청소',
        parentId: 'cleaning'
      },
      {
        id: 'dry_cleaning',
        name: '드라이 클리닝',
        parentId: 'laundry'
      },
      {
        id: 'kitchen_organizing',
        name: '주방 정리',
        parentId: 'kitchen'
      }
    ];

    // 서비스 데이터
    const services = [
      {
        name: '일반 집 청소',
        shortDescription: '집 전체를 깔끔하게 청소해 드립니다',
        description: '먼지 제거, 바닥 청소, 주방 청소, 화장실 청소 등 기본적인 집 청소 서비스입니다.',
        basePrice: 50000,
        unit: '회',
        duration: 120,
        categoryId: 'cleaning',
        subcategoryId: 'regular_cleaning',
        thumbnail: 'https://example.com/thumbnails/regular-house-cleaning.jpg'
      },
      {
        name: '에어컨 청소',
        shortDescription: '전문가의 에어컨 분해 청소 서비스',
        description: '에어컨 내부의 곰팡이와 먼지를 깨끗하게 제거하는 전문 서비스입니다.',
        basePrice: 60000,
        unit: '대당',
        duration: 90,
        categoryId: 'cleaning',
        subcategoryId: 'special_cleaning',
        thumbnail: 'https://example.com/thumbnails/ac-cleaning.jpg'
      },
      {
        name: '곰팡이 제거',
        shortDescription: '욕실, 주방 등의 곰팡이를 완벽히 제거',
        description: '전문 약품과 장비를 사용하여 집 안의 곰팡이를 제거하는 서비스입니다.',
        basePrice: 80000,
        unit: '평당',
        duration: 180,
        categoryId: 'cleaning',
        subcategoryId: 'special_cleaning',
        thumbnail: 'https://example.com/thumbnails/mold-removal.jpg'
      }
    ];

    // 카테고리 데이터 생성
    for (const category of categories) {
      const [cat, created] = await Category.findOrCreate({
        where: { id: category.id },
        defaults: category
      });
      if (created) {
        logger.info(`카테고리 생성: ${category.name}`);
      }
    }

    // 서브카테고리 데이터 생성
    for (const subcategory of subcategories) {
      const [subcat, created] = await SubCategory.findOrCreate({
        where: { id: subcategory.id },
        defaults: subcategory
      });
      if (created) {
        logger.info(`서브카테고리 생성: ${subcategory.name}`);
      }
    }

    // 서비스 데이터 생성
    for (const serviceData of services) {
      // 서비스 이름으로 중복 체크
      const existingService = await Service.findOne({ where: { name: serviceData.name } });
      
      if (!existingService) {
        // 새 서비스 생성
        const service = await Service.create(serviceData);
        logger.info(`서비스 생성: ${service.name}`);
        
        // 에어컨 청소 서비스인 경우 옵션과 커스텀 필드 추가
        if (service.name === '에어컨 청소') {
          // 서비스 옵션 생성
          await ServiceOption.create({
            serviceId: service.id,
            name: '필터 교체',
            description: '에어컨 필터를 새것으로 교체합니다.',
            price: 15000
          });
          
          await ServiceOption.create({
            serviceId: service.id,
            name: '항균 처리',
            description: '에어컨 내부를 항균 처리하여 세균 번식을 방지합니다.',
            price: 20000
          });
          
          // 커스텀 필드 생성
          await CustomField.create({
            serviceId: service.id,
            name: '에어컨 대수',
            type: 'number',
            isRequired: true,
            defaultValue: '1'
          });
          
          await CustomField.create({
            serviceId: service.id,
            name: '에어컨 종류',
            type: 'selection',
            isRequired: true,
            options: JSON.stringify(['벽걸이형', '스탠드형', '천장형', '창문형'])
          });
          
          await CustomField.create({
            serviceId: service.id,
            name: '주차 가능 여부',
            type: 'boolean',
            isRequired: false
          });
          
          logger.info('에어컨 청소 서비스의 옵션과 커스텀 필드 생성 완료');
        }
      }
    }

    logger.info('카테고리, 서브카테고리, 서비스 초기 데이터 생성 완료');
  } catch (error) {
    logger.error('초기 데이터 생성 중 오류 발생:', error);
  }
};

module.exports = seedCategoryData;