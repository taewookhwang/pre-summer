const matchingService = require('../services/matchingService');
const { validationResult } = require('express-validator');

/**
 * 매칭 컨트롤러
 */
const matchingController = {
  /**
   * 매칭 요청 생성
   */
  createMatching: async (req, res) => {
    try {
      // 요청 데이터 검증
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'Validation failed',
            details: errors.array().map((err) => ({
              field: err.param,
              message: err.msg,
            })),
          },
        });
      }

      // 매칭 데이터 준비
      const matchingData = {
        reservation_id: req.body.reservation_id,
        max_distance: req.body.max_distance,
        priority_factors: req.body.priority_factors,
      };

      // 매칭 생성
      const matching = await matchingService.createMatching(matchingData);

      // 응답 포맷팅
      const response = formatMatchingResponse(matching);

      return res.status(201).json({
        success: true,
        matching: response,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: error.message || 'Failed to create matching',
          details: error.message,
        },
      });
    }
  },

  /**
   * 매칭 정보 조회
   */
  getMatching: async (req, res) => {
    try {
      const { matchingId } = req.params;

      // 매칭 정보 조회
      const matching = await matchingService.getMatching(matchingId);

      // 응답 포맷팅
      const response = formatMatchingResponse(matching);

      return res.status(200).json({
        success: true,
        matching: response,
      });
    } catch (error) {
      return res.status(error.message === 'Matching not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to fetch matching',
          details: error.message,
        },
      });
    }
  },

  /**
   * 예약에 대한 매칭 정보 조회
   */
  getReservationMatching: async (req, res) => {
    try {
      const { reservationId } = req.params;

      // 예약에 대한 매칭 정보 조회
      const matching = await matchingService.getReservationMatching(reservationId);

      // 응답 포맷팅
      const response = formatMatchingResponse(matching);

      return res.status(200).json({
        success: true,
        matching: response,
      });
    } catch (error) {
      return res
        .status(error.message === 'Matching not found for this reservation' ? 404 : 500)
        .json({
          success: false,
          error: {
            message: error.message || 'Failed to fetch matching for reservation',
            details: error.message,
          },
        });
    }
  },

  /**
   * 매칭 취소
   */
  cancelMatching: async (req, res) => {
    try {
      const { matchingId } = req.params;

      // 매칭 취소
      const matching = await matchingService.cancelMatching(matchingId);

      // 응답 포맷팅
      const response = formatMatchingResponse(matching);

      return res.status(200).json({
        success: true,
        matching: response,
      });
    } catch (error) {
      return res.status(error.message === 'Matching not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to cancel matching',
          details: error.message,
        },
      });
    }
  },

  /**
   * 매칭 재시도
   */
  retryMatching: async (req, res) => {
    try {
      const { matchingId } = req.params;

      // 매칭 재시도
      const matching = await matchingService.retryMatching(matchingId);

      // 응답 포맷팅
      const response = formatMatchingResponse(matching);

      return res.status(200).json({
        success: true,
        matching: response,
      });
    } catch (error) {
      return res.status(error.message === 'Matching not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to retry matching',
          details: error.message,
        },
      });
    }
  },

  /**
   * 매칭 요청에 응답
   */
  respondToMatching: async (req, res) => {
    try {
      // 요청 데이터 검증
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'Validation failed',
            details: errors.array().map((err) => ({
              field: err.param,
              message: err.msg,
            })),
          },
        });
      }

      const { matchingId } = req.params;
      const technicianId = req.user.id; // auth 미들웨어에서 설정

      // 응답 데이터 준비
      const responseData = {
        accept: req.body.accept,
        decline_reason: req.body.decline_reason,
        estimated_arrival: req.body.estimated_arrival,
      };

      // 매칭 요청에 응답
      const matching = await matchingService.respondToMatching(
        matchingId,
        technicianId,
        responseData,
      );

      // 응답 포맷팅
      const response = formatMatchingResponse(matching);

      return res.status(200).json({
        success: true,
        matching: response,
      });
    } catch (error) {
      return res.status(error.message === 'Matching not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to respond to matching',
          details: error.message,
        },
      });
    }
  },
};

/**
 * 매칭 응답 포맷팅
 * @param {Object} matching - 매칭 객체
 * @returns {Object} 포맷팅된 응답
 */
function formatMatchingResponse(matching) {
  const response = {
    id: matching.id,
    reservation_id: matching.reservationId,
    status: matching.status,
    attempts: matching.attempts,
    technician_id: matching.technicianId,
    search_radius: matching.searchRadius,
    max_distance: matching.maxDistance,
    priority_factors: matching.priorityFactors,
    matched_at: matching.matchedAt,
    estimated_arrival: matching.estimatedArrival,
    created_at: matching.createdAt,
    updated_at: matching.updatedAt,
  };

  // 기술자 정보가 있는 경우 추가
  if (matching.technician) {
    response.technician = matching.technician;
  }

  // 요청 정보가 있는 경우 추가
  if (matching.requests) {
    response.requests = matching.requests.map((request) => ({
      id: request.id,
      technician_id: request.technicianId,
      status: request.status,
      distance: request.distance,
      score: request.score,
      request_expiry: request.requestExpiry,
      responded_at: request.respondedAt,
      decline_reason: request.declineReason,
      created_at: request.createdAt,
    }));
  }

  return response;
}

module.exports = matchingController;
