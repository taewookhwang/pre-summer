const express = require('express');
const router = express.Router();
const matchingController = require('../controllers/matchingController');
const validators = require('../middleware/validators');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route POST /api/matchings
 * @desc 매칭 요청 생성
 * @access Private (소비자)
 */
router.post(
  '/',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('consumer'),
  validators.validateCreateMatching,
  matchingController.createMatching,
);

/**
 * @route GET /api/matchings/:matchingId
 * @desc 매칭 정보 조회
 * @access Private
 */
router.get('/:matchingId', authMiddleware.authenticateUser, matchingController.getMatching);

/**
 * @route GET /api/reservations/:reservationId/matching
 * @desc 예약에 대한 매칭 정보 조회
 * @access Private
 */
router.get(
  '/reservations/:reservationId/matching',
  authMiddleware.authenticateUser,
  matchingController.getReservationMatching,
);

/**
 * @route POST /api/matchings/:matchingId/cancel
 * @desc 매칭 취소
 * @access Private (소비자)
 */
router.post(
  '/:matchingId/cancel',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('consumer'),
  matchingController.cancelMatching,
);

/**
 * @route POST /api/matchings/:matchingId/retry
 * @desc 매칭 재시도
 * @access Private (소비자)
 */
router.post(
  '/:matchingId/retry',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('consumer'),
  matchingController.retryMatching,
);

/**
 * @route POST /api/matchings/:matchingId/respond
 * @desc 매칭 요청에 응답 (기술자)
 * @access Private (기술자)
 */
router.post(
  '/:matchingId/respond',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('technician'),
  validators.validateRespondToMatching,
  matchingController.respondToMatching,
);

module.exports = router;
