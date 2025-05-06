const express = require('express');
const router = express.Router();
const reservationController = require('../controllers/reservationController');
const validators = require('../middleware/validators');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route POST /api/reservations
 * @desc Create a new reservation
 * @access Private
 */
router.post(
  '/',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('consumer'),
  validators.validateCreateReservation,
  reservationController.createReservation
);

/**
 * @route GET /api/reservations
 * @desc Get all user's reservations
 * @access Private
 */
router.get(
  '/',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('consumer'),
  reservationController.getUserReservations
);

/**
 * @route GET /api/reservations/:reservationId
 * @desc Get reservation by ID
 * @access Private
 */
router.get(
  '/:reservationId',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('consumer'),
  reservationController.getReservationById
);

/**
 * @route PATCH /api/reservations/:reservationId/status
 * @desc Update reservation status
 * @access Private
 */
router.patch(
  '/:reservationId/status',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('consumer'),
  validators.validateUpdateStatus,
  reservationController.updateReservationStatus
);

module.exports = router;