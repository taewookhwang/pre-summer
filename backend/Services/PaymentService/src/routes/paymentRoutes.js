const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const validators = require('../middleware/validators');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route POST /api/payments
 * @desc 결제 생성
 * @access Private
 */
router.post(
  '/',
  authMiddleware.authenticateUser,
  validators.validateCreatePayment,
  paymentController.createPayment,
);

/**
 * @route GET /api/payments/:paymentId
 * @desc 결제 정보 조회
 * @access Private
 */
router.get('/:paymentId', authMiddleware.authenticateUser, paymentController.getPayment);

/**
 * @route POST /api/payments/:paymentId/confirm
 * @desc 결제 확인
 * @access Private
 */
router.post(
  '/:paymentId/confirm',
  authMiddleware.authenticateUser,
  validators.validateConfirmPayment,
  paymentController.confirmPayment,
);

/**
 * @route POST /api/payments/:paymentId/cancel
 * @desc 결제 취소
 * @access Private
 */
router.post(
  '/:paymentId/cancel',
  authMiddleware.authenticateUser,
  validators.validateCancelPayment,
  paymentController.cancelPayment,
);

/**
 * @route POST /api/reservations/:reservationId/payment
 * @desc 예약에 결제 정보 연결
 * @access Private
 */
router.post(
  '/reservations/:reservationId/payment',
  authMiddleware.authenticateUser,
  validators.validateLinkPayment,
  paymentController.linkPaymentToReservation,
);

/**
 * @route POST /api/payments/webhook
 * @desc 결제 웹훅 핸들러
 * @access Public
 */
router.post('/webhook', paymentController.handleWebhook);

module.exports = router;
