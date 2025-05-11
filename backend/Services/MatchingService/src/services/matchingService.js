const Matching = require('../models/Matching');
const MatchingRequest = require('../models/MatchingRequest');
const logger = require('../../../../Shared/logger');
const { sequelize } = require('../../../../Shared/database');
const axios = require('axios');
const { Op } = require('sequelize');

// 외부 서비스 API 설정
const CONSUMER_SERVICE_URL = process.env.CONSUMER_SERVICE_URL || 'http://localhost:3001';
const TECHNICIAN_SERVICE_URL = process.env.TECHNICIAN_SERVICE_URL || 'http://localhost:3003';
const MAX_RETRY_ATTEMPTS = 3;
const REQUEST_EXPIRY_MINUTES = 2; // 기술자 요청 만료 시간 (분)
const MATCHING_EXPIRY_MINUTES = 10; // 전체 매칭 프로세스 만료 시간 (분)

/**
 * 매칭 서비스
 */
class MatchingService {
  /**
   * 새 매칭 요청을 생성합니다.
   * @param {Object} matchingData - 매칭 데이터
   * @returns {Promise<Object>} 생성된 매칭 정보
   */
  async createMatching(matchingData) {
    try {
      return await sequelize.transaction(async (transaction) => {
        // 진행 중인 매칭이 있는지 확인
        const existingMatching = await Matching.findOne({
          where: {
            reservationId: matchingData.reservation_id,
            status: {
              [Op.notIn]: ['matched', 'cancelled', 'expired', 'failed'],
            },
          },
          transaction,
        });

        if (existingMatching) {
          throw new Error('An active matching process already exists for this reservation');
        }

        // 예약 정보 확인 (ConsumerService API 호출)
        const reservation = await this.getReservationDetails(matchingData.reservation_id);

        // 새 매칭 생성
        const matching = await Matching.create(
          {
            reservationId: matchingData.reservation_id,
            status: 'pending',
            searchRadius: matchingData.max_distance || 3.0,
            maxDistance: matchingData.max_distance || 10.0,
            priorityFactors: matchingData.priority_factors || ['distance', 'rating', 'experience'],
          },
          { transaction },
        );

        // 매칭 프로세스 시작 (비동기)
        this.startMatchingProcess(matching.id);

        return matching;
      });
    } catch (error) {
      logger.error('Error creating matching:', error);
      throw error;
    }
  }

  /**
   * 매칭 프로세스를 시작합니다. (비동기)
   * @param {String} matchingId - 매칭 ID
   */
  async startMatchingProcess(matchingId) {
    try {
      // 매칭 정보 조회
      const matching = await Matching.findByPk(matchingId);

      if (!matching) {
        logger.error(`Matching not found: ${matchingId}`);
        return;
      }

      // 상태 업데이트
      matching.status = 'searching';
      await matching.save();

      // 소켓 이벤트 발송
      this.emitMatchingEvent('matching_started', matching);

      // 매칭 프로세스 실행
      this.findTechnicians(matching);
    } catch (error) {
      logger.error(`Error starting matching process for ${matchingId}:`, error);
      // 에러 발생 시 매칭 실패로 처리
      this.handleMatchingFailure(matchingId, error.message);
    }
  }

  /**
   * 기술자를 찾습니다.
   * @param {Object} matching - 매칭 객체
   */
  async findTechnicians(matching) {
    try {
      // 예약 정보 조회
      const reservation = await this.getReservationDetails(matching.reservationId);

      // 서비스 정보 조회
      const service = await this.getServiceDetails(reservation.service_id);

      // 현재 위치 정보
      const location = {
        latitude: reservation.address.coordinates.latitude,
        longitude: reservation.address.coordinates.longitude,
      };

      // 활성 상태인 기술자 검색
      const technicians = await this.findAvailableTechnicians(
        service.id,
        location,
        matching.searchRadius,
      );

      if (technicians.length === 0) {
        // 검색 반경 내 기술자가 없는 경우
        if (matching.searchRadius < matching.maxDistance) {
          // 검색 반경 확장
          matching.searchRadius = Math.min(matching.searchRadius * 1.5, matching.maxDistance);
          await matching.save();

          // 재시도
          return this.findTechnicians(matching);
        } else {
          // 최대 검색 반경까지 확장했는데도 기술자가 없는 경우
          throw new Error('No available technicians found within the search radius');
        }
      }

      // 상태 업데이트
      matching.status = 'technician_found';
      await matching.save();

      // 소켓 이벤트 발송
      this.emitMatchingEvent('technician_found', {
        ...matching.toJSON(),
        technicians_count: technicians.length,
      });

      // 기술자 순위 지정
      const rankedTechnicians = this.rankTechnicians(
        technicians,
        location,
        matching.priorityFactors,
      );

      // 가장 적합한 기술자에게 요청 보내기
      this.requestTechnician(matching, rankedTechnicians[0], reservation);
    } catch (error) {
      logger.error(`Error finding technicians for matching ${matching.id}:`, error);
      this.handleMatchingFailure(matching.id, error.message);
    }
  }

  /**
   * 기술자에게 작업 요청을 보냅니다.
   * @param {Object} matching - 매칭 객체
   * @param {Object} technician - 기술자 정보
   * @param {Object} reservation - 예약 정보
   */
  async requestTechnician(matching, technician, reservation) {
    try {
      // 요청 만료 시간 설정
      const requestExpiry = new Date();
      requestExpiry.setMinutes(requestExpiry.getMinutes() + REQUEST_EXPIRY_MINUTES);

      // 매칭 상태 업데이트
      matching.status = 'technician_requested';
      matching.requestExpiry = requestExpiry;
      await matching.save();

      // 매칭 요청 생성
      const matchingRequest = await MatchingRequest.create({
        matchingId: matching.id,
        technicianId: technician.id,
        status: 'pending',
        distance: technician.distance,
        score: technician.score,
        requestExpiry,
      });

      // 소켓 이벤트 발송
      this.emitMatchingEvent('technician_requested', {
        ...matching.toJSON(),
        technician: {
          id: technician.id,
          name: technician.name,
          rating: technician.rating,
          profile_image_url: technician.profile_image,
        },
        request_expiry: requestExpiry.toISOString(),
      });

      // 기술자에게 푸시 알림 전송
      this.sendPushNotificationToTechnician(
        technician.id,
        'New job request',
        `You have a new cleaning request in ${technician.distance.toFixed(1)} km distance`,
        {
          reservation_id: reservation.id,
          matching_id: matching.id,
          matching_request_id: matchingRequest.id,
          service_name: reservation.service.name,
          address: `${reservation.address.street} ${reservation.address.detail}`,
          scheduled_time: reservation.scheduled_time,
          estimated_price: reservation.estimated_price,
        },
      );

      // 타이머 설정 - 요청 만료 자동 처리
      setTimeout(
        async () => {
          try {
            // 요청 상태 확인
            const updatedRequest = await MatchingRequest.findByPk(matchingRequest.id);

            // 아직 응답하지 않은 경우 만료 처리
            if (updatedRequest.status === 'pending') {
              updatedRequest.status = 'expired';
              await updatedRequest.save();

              // 다음 기술자에게 요청
              this.handleTechnicianRequestExpiry(matching.id);
            }
          } catch (error) {
            logger.error(`Error processing expired request ${matchingRequest.id}:`, error);
          }
        },
        REQUEST_EXPIRY_MINUTES * 60 * 1000,
      );
    } catch (error) {
      logger.error(`Error requesting technician for matching ${matching.id}:`, error);
      this.handleMatchingFailure(matching.id, error.message);
    }
  }

  /**
   * 매칭 요청 만료를 처리합니다.
   * @param {String} matchingId - 매칭 ID
   */
  async handleTechnicianRequestExpiry(matchingId) {
    try {
      // 매칭 정보 조회
      const matching = await Matching.findByPk(matchingId, {
        include: [
          {
            model: MatchingRequest,
            as: 'requests',
          },
        ],
      });

      if (!matching) {
        logger.error(`Matching not found: ${matchingId}`);
        return;
      }

      // 이미 완료된 매칭인 경우 처리하지 않음
      if (['matched', 'cancelled', 'expired', 'failed'].includes(matching.status)) {
        return;
      }

      // 요청 횟수가 최대 시도 횟수를 초과한 경우
      if (matching.attempts >= MAX_RETRY_ATTEMPTS) {
        return this.handleMatchingFailure(matchingId, 'Maximum retry attempts reached');
      }

      // 예약 정보 조회
      const reservation = await this.getReservationDetails(matching.reservationId);

      // 현재 위치 정보
      const location = {
        latitude: reservation.address.coordinates.latitude,
        longitude: reservation.address.coordinates.longitude,
      };

      // 이미 요청했던 기술자 ID 목록
      const requestedTechnicianIds = matching.requests.map((req) => req.technicianId);

      // 다음 기술자 검색
      const technicians = await this.findAvailableTechnicians(
        reservation.service_id,
        location,
        matching.searchRadius,
        requestedTechnicianIds,
      );

      if (technicians.length === 0) {
        // 검색 반경 내 기술자가 없는 경우
        if (matching.searchRadius < matching.maxDistance) {
          // 검색 반경 확장
          matching.searchRadius = Math.min(matching.searchRadius * 1.5, matching.maxDistance);
          matching.attempts += 1;
          await matching.save();

          // 기술자 다시 검색
          return this.findTechnicians(matching);
        } else {
          // 최대 검색 반경까지 확장했는데도 기술자가 없는 경우
          throw new Error('No more available technicians');
        }
      }

      // 기술자 순위 지정
      const rankedTechnicians = this.rankTechnicians(
        technicians,
        location,
        matching.priorityFactors,
      );

      // 시도 횟수 증가
      matching.attempts += 1;
      await matching.save();

      // 다음 기술자에게 요청
      this.requestTechnician(matching, rankedTechnicians[0], reservation);
    } catch (error) {
      logger.error(`Error handling request expiry for matching ${matchingId}:`, error);
      this.handleMatchingFailure(matchingId, error.message);
    }
  }

  /**
   * 기술자의 매칭 요청 응답을 처리합니다.
   * @param {String} matchingId - 매칭 ID
   * @param {Number} technicianId - 기술자 ID
   * @param {Object} responseData - 응답 데이터
   * @returns {Promise<Object>} 업데이트된 매칭 정보
   */
  async respondToMatching(matchingId, technicianId, responseData) {
    try {
      return await sequelize.transaction(async (transaction) => {
        // 매칭 정보 조회
        const matching = await Matching.findByPk(matchingId, { transaction });

        if (!matching) {
          throw new Error('Matching not found');
        }

        // 이미 완료된 매칭인 경우
        if (['matched', 'cancelled', 'expired', 'failed'].includes(matching.status)) {
          throw new Error(`Cannot respond to matching with status: ${matching.status}`);
        }

        // 매칭 요청 찾기
        const matchingRequest = await MatchingRequest.findOne({
          where: {
            matchingId,
            technicianId,
            status: 'pending',
          },
          transaction,
        });

        if (!matchingRequest) {
          throw new Error('Matching request not found or already processed');
        }

        // 요청이 만료되었는지 확인
        if (new Date() > matchingRequest.requestExpiry) {
          matchingRequest.status = 'expired';
          await matchingRequest.save({ transaction });
          throw new Error('Matching request has expired');
        }

        // 응답 처리
        const isAccepted = responseData.accept === true;

        if (isAccepted) {
          // 수락 처리
          matchingRequest.status = 'accepted';
          matchingRequest.respondedAt = new Date();
          await matchingRequest.save({ transaction });

          // 매칭 정보 업데이트
          matching.status = 'matched';
          matching.technicianId = technicianId;
          matching.matchedAt = new Date();

          // 도착 예상 시간 설정
          if (responseData.estimated_arrival) {
            matching.estimatedArrival = new Date(responseData.estimated_arrival);
          } else {
            // 기본 도착 예상 시간 (현재 + 30분)
            const eta = new Date();
            eta.setMinutes(eta.getMinutes() + 30);
            matching.estimatedArrival = eta;
          }

          await matching.save({ transaction });

          // 예약 상태 업데이트 (ConsumerService API 호출)
          await this.updateReservationStatus(
            matching.reservationId,
            'technician_assigned',
            technicianId,
          );

          // 작업 생성 (TechnicianService API 호출)
          await this.createJob(matching.reservationId, technicianId);

          // 소켓 이벤트 발송
          this.emitMatchingEvent('technician_accepted', {
            ...matching.toJSON(),
            technician: await this.getTechnicianDetails(technicianId),
          });

          // 소비자에게 푸시 알림 전송
          const reservation = await this.getReservationDetails(matching.reservationId);
          this.sendPushNotificationToConsumer(
            reservation.user_id,
            'Technician assigned',
            'A technician has been assigned to your cleaning request',
            {
              reservation_id: matching.reservationId,
              matching_id: matching.id,
              technician_id: technicianId,
            },
          );
        } else {
          // 거절 처리
          matchingRequest.status = 'declined';
          matchingRequest.respondedAt = new Date();
          matchingRequest.declineReason = responseData.decline_reason;
          await matchingRequest.save({ transaction });

          // 소켓 이벤트 발송
          this.emitMatchingEvent('technician_declined', {
            matching_id: matching.id,
            reservation_id: matching.reservationId,
            technician_id: technicianId,
            reason: responseData.decline_reason,
          });

          // 다음 기술자에게 요청
          // 트랜잭션 외부에서 처리 (비동기)
          setTimeout(() => {
            this.handleTechnicianRequestExpiry(matching.id);
          }, 0);
        }

        return matching;
      });
    } catch (error) {
      logger.error(`Error responding to matching ${matchingId}:`, error);
      throw error;
    }
  }

  /**
   * 매칭 정보를 조회합니다.
   * @param {String} matchingId - 매칭 ID
   * @returns {Promise<Object>} 매칭 정보
   */
  async getMatching(matchingId) {
    try {
      const matching = await Matching.findByPk(matchingId, {
        include: [
          {
            model: MatchingRequest,
            as: 'requests',
          },
        ],
      });

      if (!matching) {
        throw new Error('Matching not found');
      }

      // 추가 정보 조회
      const result = matching.toJSON();

      // 기술자 정보 추가
      if (matching.technicianId) {
        result.technician = await this.getTechnicianDetails(matching.technicianId);
      }

      return result;
    } catch (error) {
      logger.error(`Error fetching matching with id ${matchingId}:`, error);
      throw error;
    }
  }

  /**
   * 예약에 대한 매칭 정보를 조회합니다.
   * @param {String} reservationId - 예약 ID
   * @returns {Promise<Object>} 매칭 정보
   */
  async getReservationMatching(reservationId) {
    try {
      const matching = await Matching.findOne({
        where: { reservationId },
        order: [['createdAt', 'DESC']],
      });

      if (!matching) {
        throw new Error('Matching not found for this reservation');
      }

      return this.getMatching(matching.id);
    } catch (error) {
      logger.error(`Error fetching matching for reservation ${reservationId}:`, error);
      throw error;
    }
  }

  /**
   * 매칭을 취소합니다.
   * @param {String} matchingId - 매칭 ID
   * @returns {Promise<Object>} 업데이트된 매칭 정보
   */
  async cancelMatching(matchingId) {
    try {
      const matching = await Matching.findByPk(matchingId);

      if (!matching) {
        throw new Error('Matching not found');
      }

      // 이미 완료된 매칭인 경우
      if (['matched', 'cancelled', 'expired', 'failed'].includes(matching.status)) {
        throw new Error(`Cannot cancel matching with status: ${matching.status}`);
      }

      // 매칭 취소
      matching.status = 'cancelled';
      await matching.save();

      // 소켓 이벤트 발송
      this.emitMatchingEvent('matching_cancelled', {
        matching_id: matching.id,
        reservation_id: matching.reservationId,
        cancelled_by: 'user',
      });

      return matching;
    } catch (error) {
      logger.error(`Error cancelling matching ${matchingId}:`, error);
      throw error;
    }
  }

  /**
   * 매칭을 재시도합니다.
   * @param {String} matchingId - 매칭 ID
   * @returns {Promise<Object>} 업데이트된 매칭 정보
   */
  async retryMatching(matchingId) {
    try {
      const matching = await Matching.findByPk(matchingId);

      if (!matching) {
        throw new Error('Matching not found');
      }

      // 재시도 가능한 상태인지 확인
      if (!['failed', 'expired'].includes(matching.status)) {
        throw new Error(`Cannot retry matching with status: ${matching.status}`);
      }

      // 매칭 상태 초기화
      matching.status = 'pending';
      matching.attempts = 0;
      await matching.save();

      // 매칭 프로세스 다시 시작
      this.startMatchingProcess(matching.id);

      return matching;
    } catch (error) {
      logger.error(`Error retrying matching ${matchingId}:`, error);
      throw error;
    }
  }

  /**
   * 매칭 실패를 처리합니다.
   * @param {String} matchingId - 매칭 ID
   * @param {String} reason - 실패 이유
   */
  async handleMatchingFailure(matchingId, reason) {
    try {
      const matching = await Matching.findByPk(matchingId);

      if (!matching) {
        logger.error(`Matching not found: ${matchingId}`);
        return;
      }

      // 이미 완료된 매칭인 경우 처리하지 않음
      if (['matched', 'cancelled', 'expired', 'failed'].includes(matching.status)) {
        return;
      }

      // 매칭 실패로 상태 업데이트
      matching.status = 'failed';
      await matching.save();

      // 소켓 이벤트 발송
      this.emitMatchingEvent('matching_failed', {
        matching_id: matching.id,
        reservation_id: matching.reservationId,
        reason,
        attempts: matching.attempts,
        retry_available: matching.attempts < MAX_RETRY_ATTEMPTS,
      });

      // 소비자에게 푸시 알림 전송
      const reservation = await this.getReservationDetails(matching.reservationId);
      this.sendPushNotificationToConsumer(
        reservation.user_id,
        'Matching failed',
        'We could not find a technician for your request. Please try again.',
        {
          reservation_id: matching.reservationId,
          matching_id: matching.id,
          reason,
        },
      );
    } catch (error) {
      logger.error(`Error handling matching failure for ${matchingId}:`, error);
    }
  }

  /**
   * 이용 가능한 기술자를 찾습니다.
   * @param {String} serviceId - 서비스 ID
   * @param {Object} location - 위치 정보
   * @param {Number} radius - 검색 반경 (km)
   * @param {Array} excludeTechnicianIds - 제외할 기술자 ID 목록
   * @returns {Promise<Array>} 기술자 목록
   */
  async findAvailableTechnicians(serviceId, location, radius, excludeTechnicianIds = []) {
    try {
      // TechnicianService API 호출
      const response = await axios.get(`${TECHNICIAN_SERVICE_URL}/api/technicians/available`, {
        params: {
          service_id: serviceId,
          latitude: location.latitude,
          longitude: location.longitude,
          radius,
          exclude_technicians: excludeTechnicianIds.join(','),
        },
      });

      return response.data.technicians;
    } catch (error) {
      logger.error('Error finding available technicians:', error);
      throw error;
    }
  }

  /**
   * 기술자에게 우선순위를 부여합니다.
   * @param {Array} technicians - 기술자 목록
   * @param {Object} location - 위치 정보
   * @param {Array} priorityFactors - 우선순위 요소 목록
   * @returns {Array} 순위가 매겨진 기술자 목록
   */
  rankTechnicians(technicians, location, priorityFactors) {
    // 가중치 설정
    const weights = {
      distance: 0.6, // 거리: 60%
      rating: 0.3, // 평점: 30%
      experience: 0.1, // 경험: 10%
    };

    // 각 기술자에게 점수 부여
    const scoredTechnicians = technicians.map((technician) => {
      // 거리 점수 (가까울수록 높은 점수)
      const distanceScore = 1 - technician.distance / 10; // 최대 10km 기준

      // 평점 점수 (높을수록 높은 점수)
      const ratingScore = technician.rating / 5; // 최대 5점 기준

      // 경험 점수 (많을수록 높은 점수)
      const experienceScore = Math.min(technician.completed_jobs / 100, 1); // 최대 100건 기준

      // 종합 점수 계산
      let totalScore = 0;

      priorityFactors.forEach((factor) => {
        switch (factor) {
          case 'distance':
            totalScore += distanceScore * weights.distance;
            break;
          case 'rating':
            totalScore += ratingScore * weights.rating;
            break;
          case 'experience':
            totalScore += experienceScore * weights.experience;
            break;
        }
      });

      return {
        ...technician,
        score: totalScore,
      };
    });

    // 점수 기준으로 정렬
    return scoredTechnicians.sort((a, b) => b.score - a.score);
  }

  /**
   * 예약 정보를 조회합니다.
   * @param {String} reservationId - 예약 ID
   * @returns {Promise<Object>} 예약 정보
   */
  async getReservationDetails(reservationId) {
    try {
      const response = await axios.get(`${CONSUMER_SERVICE_URL}/api/reservations/${reservationId}`);
      return response.data.reservation;
    } catch (error) {
      logger.error(`Error fetching reservation details for ${reservationId}:`, error);
      throw error;
    }
  }

  /**
   * 서비스 정보를 조회합니다.
   * @param {String} serviceId - 서비스 ID
   * @returns {Promise<Object>} 서비스 정보
   */
  async getServiceDetails(serviceId) {
    try {
      const response = await axios.get(`${CONSUMER_SERVICE_URL}/api/services/${serviceId}`);
      return response.data.service;
    } catch (error) {
      logger.error(`Error fetching service details for ${serviceId}:`, error);
      throw error;
    }
  }

  /**
   * 기술자 정보를 조회합니다.
   * @param {Number} technicianId - 기술자 ID
   * @returns {Promise<Object>} 기술자 정보
   */
  async getTechnicianDetails(technicianId) {
    try {
      const response = await axios.get(`${TECHNICIAN_SERVICE_URL}/api/technicians/${technicianId}`);

      // 필요한 정보만 추출
      const { id, name, profile_image, rating, total_jobs, completed_jobs, phone } =
        response.data.technician;

      return {
        id,
        name,
        profile_image_url: profile_image,
        rating,
        total_jobs,
        completed_jobs,
        phone,
      };
    } catch (error) {
      logger.error(`Error fetching technician details for ${technicianId}:`, error);
      throw error;
    }
  }

  /**
   * 예약 상태를 업데이트합니다.
   * @param {String} reservationId - 예약 ID
   * @param {String} status - 상태
   * @param {Number} technicianId - 기술자 ID
   * @returns {Promise<Object>} 업데이트된 예약 정보
   */
  async updateReservationStatus(reservationId, status, technicianId) {
    try {
      const response = await axios.patch(
        `${CONSUMER_SERVICE_URL}/api/reservations/${reservationId}/status`,
        {
          status,
          technician_id: technicianId,
        },
      );

      return response.data.reservation;
    } catch (error) {
      logger.error(`Error updating reservation status for ${reservationId}:`, error);
      throw error;
    }
  }

  /**
   * 작업을 생성합니다.
   * @param {String} reservationId - 예약 ID
   * @param {Number} technicianId - 기술자 ID
   * @returns {Promise<Object>} 생성된 작업 정보
   */
  async createJob(reservationId, technicianId) {
    try {
      const response = await axios.post(`${TECHNICIAN_SERVICE_URL}/api/jobs`, {
        reservation_id: reservationId,
        technician_id: technicianId,
      });

      return response.data.job;
    } catch (error) {
      logger.error(`Error creating job for reservation ${reservationId}:`, error);
      throw error;
    }
  }

  /**
   * 소켓 이벤트를 발송합니다.
   * @param {String} eventType - 이벤트 타입
   * @param {Object} data - 이벤트 데이터
   */
  emitMatchingEvent(eventType, data) {
    // TODO: Socket.IO 이벤트 발송 로직 구현
    // 현재는 로깅만 수행
    logger.info(`Emitting ${eventType} event:`, data);
  }

  /**
   * 소비자에게 푸시 알림을 전송합니다.
   * @param {Number} userId - 사용자 ID
   * @param {String} title - 알림 제목
   * @param {String} body - 알림 내용
   * @param {Object} data - 알림 데이터
   */
  async sendPushNotificationToConsumer(userId, title, body, data) {
    // TODO: 푸시 알림 전송 로직 구현
    // 현재는 로깅만 수행
    logger.info(`Sending push notification to consumer ${userId}:`, { title, body, data });
  }

  /**
   * 기술자에게 푸시 알림을 전송합니다.
   * @param {Number} technicianId - 기술자 ID
   * @param {String} title - 알림 제목
   * @param {String} body - 알림 내용
   * @param {Object} data - 알림 데이터
   */
  async sendPushNotificationToTechnician(technicianId, title, body, data) {
    // TODO: 푸시 알림 전송 로직 구현
    // 현재는 로깅만 수행
    logger.info(`Sending push notification to technician ${technicianId}:`, { title, body, data });
  }
}

module.exports = new MatchingService();
