const { Service, Category, SubCategory, ServiceOption, CustomField } = require('../models');
const Reservation = require('../models/Reservation');
const { Op } = require('sequelize');
const logger = require('../../../../Shared/logger');
const { sequelize } = require('../../../../Shared/database');

/**
 * 소비자 서비스 관련 기능을 제공하는 클래스
 *
 * 서비스 카테고리 조회, 서비스 검색, 예약 관리 등 소비자 관련 기능을 처리합니다.
 *
 * @class
 */
class ConsumerService {
  /**
   * 모든 서비스 카테고리와 하위 카테고리를 조회합니다.
   *
   * 활성화된 카테고리와 해당 카테고리에 속한 하위 카테고리만 반환합니다.
   *
   * @async
   * @returns {Promise<Array<Category>>} 카테고리 목록 (하위 카테고리 포함)
   * @throws {Error} 데이터베이스 조회 실패 시 오류
   */
  async getServiceCategories() {
    try {
      // 카테고리와 서브카테고리 조인하여 가져오기
      const categories = await Category.findAll({
        where: { isActive: true },
        include: [
          {
            model: SubCategory,
            as: 'subcategories',
            where: { isActive: true },
            required: false,
          },
        ],
        order: [
          ['name', 'ASC'],
          [{ model: SubCategory, as: 'subcategories' }, 'name', 'ASC'],
        ],
      });

      return categories;
    } catch (error) {
      logger.error('Error fetching service categories:', error);
      throw error;
    }
  }

  /**
   * 특정 카테고리에 속한 하위 카테고리를 조회합니다.
   *
   * @async
   * @param {string} categoryId - 상위 카테고리 ID
   * @returns {Promise<Array<SubCategory>>} 하위 카테고리 목록
   * @throws {Error} 데이터베이스 조회 실패 시 오류
   */
  async getSubcategoriesByCategory(categoryId) {
    try {
      const subcategories = await SubCategory.findAll({
        where: {
          parentId: categoryId,
          isActive: true,
        },
        order: [['name', 'ASC']],
      });

      return subcategories;
    } catch (error) {
      logger.error(`Error fetching subcategories for category ${categoryId}:`, error);
      throw error;
    }
  }

  /**
   * 특정 카테고리 또는 하위 카테고리에 속한 서비스 목록을 페이지네이션과 함께 조회합니다.
   *
   * @async
   * @param {string} categoryId - 카테고리 ID
   * @param {string} [subcategoryId=null] - 하위 카테고리 ID (선택적)
   * @param {number} [page=1] - 페이지 번호 (1부터 시작)
   * @param {number} [limit=20] - 페이지당 항목 수
   * @returns {Promise<Object>} 서비스 목록 및 페이지네이션 정보
   * @returns {Array<Service>} result.services - 서비스 목록
   * @returns {Object} result.pagination - 페이지네이션 정보
   * @returns {number} result.pagination.total - 전체 항목 수
   * @returns {number} result.pagination.page - 현재 페이지
   * @returns {number} result.pagination.limit - 페이지당 항목 수
   * @returns {number} result.pagination.total_pages - 전체 페이지 수
   * @throws {Error} 데이터베이스 조회 실패 시 오류
   */
  async getServicesByCategory(categoryId, subcategoryId = null, page = 1, limit = 20) {
    try {
      const whereClause = {
        categoryId,
        isActive: true,
      };

      if (subcategoryId) {
        whereClause.subcategoryId = subcategoryId;
      }

      // Calculate offset based on page and limit
      const offset = (page - 1) * limit;

      // Get total count for pagination metadata
      const count = await Service.count({ where: whereClause });

      // Get paginated services
      const services = await Service.findAll({
        where: whereClause,
        order: [['name', 'ASC']],
        limit: parseInt(limit),
        offset: parseInt(offset),
      });

      return {
        services,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: Math.ceil(count / limit),
        },
      };
    } catch (error) {
      logger.error('Error fetching services by category:', error);
      throw error;
    }
  }

  /**
   * Get list of available services with pagination
   * @param {Object} filters - Optional filters for services
   * @param {Number} page - Page number (1-based, defaults to 1)
   * @param {Number} limit - Number of items per page (defaults to 20)
   * @returns {Promise<Object>} Object containing services array and pagination metadata
   */
  async getServices(filters = {}, page = 1, limit = 20) {
    try {
      const whereClause = { isActive: true };

      if (filters.category) {
        whereClause.categoryId = filters.category;
      }

      if (filters.subcategory) {
        whereClause.subcategoryId = filters.subcategory;
      }

      if (filters.minPrice && filters.maxPrice) {
        whereClause.basePrice = {
          [Op.between]: [filters.minPrice, filters.maxPrice],
        };
      } else if (filters.minPrice) {
        whereClause.basePrice = {
          [Op.gte]: filters.minPrice,
        };
      } else if (filters.maxPrice) {
        whereClause.basePrice = {
          [Op.lte]: filters.maxPrice,
        };
      }

      // Calculate offset based on page and limit
      const offset = (page - 1) * limit;

      // Get total count for pagination metadata
      const count = await Service.count({ where: whereClause });

      // Get paginated services with related category and subcategory info
      const services = await Service.findAll({
        where: whereClause,
        include: [
          {
            model: Category,
            as: 'category',
            attributes: ['id', 'name'],
          },
          {
            model: SubCategory,
            as: 'subcategory',
            attributes: ['id', 'name', 'parentId'],
          },
        ],
        order: [['name', 'ASC']],
        limit: parseInt(limit),
        offset: parseInt(offset),
      });

      return {
        services,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: Math.ceil(count / limit),
        },
      };
    } catch (error) {
      logger.error('Error fetching services:', error);
      throw error;
    }
  }

  /**
   * Get service by id with all details
   * @param {String} serviceId - The service ID
   * @returns {Promise<Object>} Service object with all related details
   */
  async getServiceById(serviceId) {
    try {
      const service = await Service.findOne({
        where: {
          id: serviceId,
          isActive: true,
        },
        include: [
          {
            model: Category,
            as: 'category',
            attributes: ['id', 'name'],
          },
          {
            model: SubCategory,
            as: 'subcategory',
            attributes: ['id', 'name', 'parentId'],
          },
          {
            model: ServiceOption,
            as: 'options',
            where: { isActive: true },
            required: false,
          },
          {
            model: CustomField,
            as: 'customFields',
            required: false,
          },
        ],
      });

      if (!service) {
        throw new Error('Service not found');
      }

      // TODO: 서비스 리뷰 정보 가져오기
      // 현재는 더미 데이터로 구현
      const ratings = {
        average: 4.8,
        count: 254,
      };

      const reviews = [
        {
          id: '1',
          user_name: '홍길동',
          rating: 5.0,
          content: '아주 꼼꼼하게 청소해주셨어요!',
          created_at: new Date(Date.now() - 86400000).toISOString(),
        },
        {
          id: '2',
          user_name: '김철수',
          rating: 4.5,
          content: '친절하고 정확하게 서비스 해주셨습니다.',
          created_at: new Date(Date.now() - 172800000).toISOString(),
        },
      ];

      // 응답 데이터에 리뷰 정보 추가
      service.dataValues.ratings = ratings;
      service.dataValues.reviews = reviews;

      return service;
    } catch (error) {
      logger.error(`Error fetching service with id ${serviceId}:`, error);
      throw error;
    }
  }

  /**
   * Create a new reservation
   * @param {Object} reservationData - Reservation details
   * @returns {Promise<Object>} Created reservation
   */
  async createReservation(reservationData) {
    try {
      // 트랜잭션 시작
      const result = await sequelize.transaction(async (transaction) => {
        // 서비스 정보 가져오기
        const service = await Service.findByPk(reservationData.serviceId, {
          include: [
            {
              model: ServiceOption,
              as: 'options',
              where: { isActive: true },
              required: false,
            },
          ],
          transaction,
        });

        if (!service) {
          throw new Error('Service not found');
        }

        // 선택한 옵션 가격 계산
        let optionsPrice = 0;
        if (reservationData.serviceOptions && Array.isArray(reservationData.serviceOptions)) {
          const selectedOptions = reservationData.serviceOptions.map((opt) => opt.option_id);
          const serviceOptions = service.options.filter((opt) => selectedOptions.includes(opt.id));

          optionsPrice = serviceOptions.reduce((total, option) => {
            const quantity =
              reservationData.serviceOptions.find((opt) => opt.option_id === option.id)?.quantity ||
              1;
            return total + option.price * quantity;
          }, 0);
        }

        // 총 가격 및 예상 소요시간 계산
        const estimatedPrice = parseFloat(service.basePrice) + optionsPrice;
        const estimatedDuration = service.duration;

        // 예약 정보 생성
        const reservation = await Reservation.create(
          {
            userId: reservationData.userId,
            serviceId: reservationData.serviceId,
            scheduledTime: reservationData.scheduledTime,
            street: reservationData.address.street,
            detail: reservationData.address.detail,
            postalCode: reservationData.address.postalCode,
            latitude: reservationData.address.coordinates?.latitude,
            longitude: reservationData.address.coordinates?.longitude,
            specialInstructions: reservationData.specialInstructions,
            serviceOptions: reservationData.serviceOptions,
            customFields: reservationData.customFields,
            estimatedPrice,
            estimatedDuration,
            status: 'pending',
            currentStep: 'pending_payment',
          },
          { transaction },
        );

        return reservation;
      });

      return result;
    } catch (error) {
      logger.error('Error creating reservation:', error);
      throw error;
    }
  }

  /**
   * Get reservations for a consumer with pagination
   * @param {Number} userId - The user ID
   * @param {Object} filters - Optional filters
   * @param {Number} page - Page number (1-based, defaults to 1)
   * @param {Number} limit - Number of items per page (defaults to 20)
   * @returns {Promise<Object>} Object containing reservations array and pagination metadata
   */
  async getUserReservations(userId, filters = {}, page = 1, limit = 20) {
    try {
      const whereClause = { userId };

      // Filter by status if provided
      if (filters.status) {
        whereClause.status = filters.status;
      }

      // Filter by date range if provided
      if (filters.startDate && filters.endDate) {
        whereClause.scheduledTime = {
          [Op.between]: [filters.startDate, filters.endDate],
        };
      } else if (filters.startDate) {
        whereClause.scheduledTime = {
          [Op.gte]: filters.startDate,
        };
      } else if (filters.endDate) {
        whereClause.scheduledTime = {
          [Op.lte]: filters.endDate,
        };
      }

      // Calculate offset based on page and limit
      const offset = (page - 1) * limit;

      // Get total count for pagination metadata
      const count = await Reservation.count({ where: whereClause });

      // Get paginated reservations
      const reservations = await Reservation.findAll({
        where: whereClause,
        include: [
          {
            model: Service,
            attributes: [
              'id',
              'name',
              'shortDescription',
              'description',
              'basePrice',
              'duration',
              'categoryId',
              'subcategoryId',
            ],
          },
        ],
        order: [['scheduledTime', 'DESC']],
        limit: parseInt(limit),
        offset: parseInt(offset),
      });

      return {
        reservations,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          total_pages: Math.ceil(count / limit),
        },
      };
    } catch (error) {
      logger.error(`Error fetching reservations for user ${userId}:`, error);
      throw error;
    }
  }

  /**
   * Get reservation by id
   * @param {String} reservationId - The reservation ID
   * @param {Number} userId - The user ID (for security check)
   * @returns {Promise<Object>} Reservation object
   */
  async getReservationById(reservationId, userId) {
    try {
      const reservation = await Reservation.findOne({
        where: {
          id: reservationId,
          userId,
        },
        include: [
          {
            model: Service,
            attributes: [
              'id',
              'name',
              'shortDescription',
              'description',
              'basePrice',
              'duration',
              'categoryId',
              'subcategoryId',
            ],
          },
        ],
      });

      if (!reservation) {
        throw new Error('Reservation not found');
      }

      return reservation;
    } catch (error) {
      logger.error(`Error fetching reservation with id ${reservationId}:`, error);
      throw error;
    }
  }

  /**
   * Update reservation
   * @param {String} reservationId - The reservation ID
   * @param {Number} userId - The user ID (for security check)
   * @param {Object} updateData - The data to update
   * @returns {Promise<Object>} Updated reservation
   */
  async updateReservation(reservationId, userId, updateData) {
    try {
      // 예약 정보 확인
      const reservation = await this.getReservationById(reservationId, userId);

      // 상태 체크: pending 상태일 때만 수정 가능
      if (reservation.status !== 'pending') {
        throw new Error('Can only update reservations in pending status');
      }

      // 트랜잭션 시작
      const result = await sequelize.transaction(async (transaction) => {
        // 수정 가능한 필드들만 업데이트
        if (updateData.scheduledTime) reservation.scheduledTime = updateData.scheduledTime;
        if (updateData.street) reservation.street = updateData.street;
        if (updateData.detail) reservation.detail = updateData.detail;
        if (updateData.postalCode) reservation.postalCode = updateData.postalCode;
        if (updateData.coordinates) {
          if (updateData.coordinates.latitude)
            reservation.latitude = updateData.coordinates.latitude;
          if (updateData.coordinates.longitude)
            reservation.longitude = updateData.coordinates.longitude;
        }
        if (updateData.specialInstructions)
          reservation.specialInstructions = updateData.specialInstructions;

        // 서비스 옵션 수정 시 가격 재계산
        if (updateData.serviceOptions) {
          const service = await Service.findByPk(reservation.serviceId, {
            include: [
              {
                model: ServiceOption,
                as: 'options',
                where: { isActive: true },
                required: false,
              },
            ],
            transaction,
          });

          // 선택한 옵션 가격 계산
          let optionsPrice = 0;
          const selectedOptions = updateData.serviceOptions.map((opt) => opt.option_id);
          const serviceOptions = service.options.filter((opt) => selectedOptions.includes(opt.id));

          optionsPrice = serviceOptions.reduce((total, option) => {
            const quantity =
              updateData.serviceOptions.find((opt) => opt.option_id === option.id)?.quantity || 1;
            return total + option.price * quantity;
          }, 0);

          // 총 가격 업데이트
          reservation.estimatedPrice = parseFloat(service.basePrice) + optionsPrice;
          reservation.serviceOptions = updateData.serviceOptions;
        }

        // 커스텀 필드 수정
        if (updateData.customFields) {
          reservation.customFields = updateData.customFields;
        }

        // 변경 사항 저장
        await reservation.save({ transaction });

        return reservation;
      });

      return result;
    } catch (error) {
      logger.error('Error updating reservation:', error);
      throw error;
    }
  }

  /**
   * Update reservation status (e.g. cancel)
   * @param {String} reservationId - The reservation ID
   * @param {Number} userId - The user ID (for security check)
   * @param {String} status - New status
   * @returns {Promise<Object>} Updated reservation
   */
  async updateReservationStatus(reservationId, userId, status) {
    try {
      const allowedStatuses = [
        'pending',
        'searching_technician',
        'technician_assigned',
        'in_progress',
        'completed',
        'cancelled',
      ];

      if (!allowedStatuses.includes(status)) {
        throw new Error('Invalid status value');
      }

      const reservation = await this.getReservationById(reservationId, userId);

      // 상태 변경 유효성 체크
      if (status === 'cancelled') {
        // 완료된 예약은 취소 불가
        if (['completed'].includes(reservation.status)) {
          throw new Error('Cannot cancel a completed reservation');
        }

        // 진행 중인 예약 취소는 일부 제한
        if (['in_progress'].includes(reservation.status)) {
          throw new Error('Cannot cancel a reservation that is in progress');
        }
      }

      // 상태 업데이트
      reservation.status = status;

      // 취소 시에는 현재 단계도 업데이트
      if (status === 'cancelled') {
        reservation.currentStep = 'cancelled';
      }

      await reservation.save();

      return reservation;
    } catch (error) {
      logger.error('Error updating reservation status:', error);
      throw error;
    }
  }

  /**
   * Get reservation status
   * @param {String} reservationId - The reservation ID
   * @returns {Promise<Object>} Reservation status info
   */
  async getReservationStatus(reservationId) {
    try {
      const reservation = await Reservation.findByPk(reservationId, {
        attributes: ['id', 'status', 'currentStep', 'technicianId', 'scheduledTime'],
      });

      if (!reservation) {
        throw new Error('Reservation not found');
      }

      // 기술자 정보가 있으면 기술자 정보 추가
      let technicianInfo = null;
      if (reservation.technicianId) {
        // TODO: User 모델에서 기술자 정보 가져오기
        // 현재는 더미 데이터
        technicianInfo = {
          id: reservation.technicianId,
          name: '김기술',
          photo_url: 'https://example.com/technicians/photo1.jpg',
          rating: 4.9,
        };
      }

      // 예상 도착 시간 (ETA) - 현재는 더미 데이터
      let eta = null;
      if (reservation.status === 'technician_assigned') {
        eta = new Date(Date.now() + 30 * 60000).toISOString(); // 30분 후
      }

      // 다음 단계 정보 - 현재 단계에 따라 결정
      const nextSteps = [];
      switch (reservation.currentStep) {
        case 'pending_payment':
          nextSteps.push('finding_technician');
          break;
        case 'finding_technician':
          nextSteps.push('technician_assigned');
          break;
        case 'technician_assigned':
          nextSteps.push('technician_on_way');
          break;
        case 'technician_on_way':
          nextSteps.push('service_in_progress');
          break;
        case 'service_in_progress':
          nextSteps.push('service_completed');
          break;
        default:
          break;
      }

      return {
        reservation_id: reservation.id,
        status: reservation.status,
        current_step: reservation.currentStep,
        technician: technicianInfo,
        eta,
        next_steps: nextSteps,
      };
    } catch (error) {
      logger.error('Error fetching reservation status:', error);
      throw error;
    }
  }
}

module.exports = new ConsumerService();
