const { body, param } = require('express-validator');

const validators = {
  /**
   * 결제 생성 요청 검증
   */
  validateCreatePayment: [
    body('reservation_id')
      .notEmpty()
      .withMessage('Reservation ID is required')
      .isUUID()
      .withMessage('Invalid Reservation ID format'),

    body('amount')
      .notEmpty()
      .withMessage('Amount is required')
      .isFloat({ min: 0 })
      .withMessage('Amount must be a positive number'),

    body('payment_method')
      .notEmpty()
      .withMessage('Payment method is required')
      .isIn(['card', 'vbank', 'phone'])
      .withMessage('Invalid payment method'),
  ],

  /**
   * 결제 확인 요청 검증
   */
  validateConfirmPayment: [
    param('paymentId')
      .notEmpty()
      .withMessage('Payment ID is required')
      .isUUID()
      .withMessage('Invalid Payment ID format'),

    body('payment_status')
      .notEmpty()
      .withMessage('Payment status is required')
      .isIn(['confirmed', 'failed'])
      .withMessage('Invalid payment status'),

    body('transaction_id').notEmpty().withMessage('Transaction ID is required'),
  ],

  /**
   * 결제 취소 요청 검증
   */
  validateCancelPayment: [
    param('paymentId')
      .notEmpty()
      .withMessage('Payment ID is required')
      .isUUID()
      .withMessage('Invalid Payment ID format'),

    body('reason')
      .notEmpty()
      .withMessage('Cancellation reason is required')
      .isLength({ max: 200 })
      .withMessage('Reason must be less than 200 characters'),
  ],

  /**
   * 예약에 결제 정보 연결 요청 검증
   */
  validateLinkPayment: [
    param('reservationId')
      .notEmpty()
      .withMessage('Reservation ID is required')
      .isUUID()
      .withMessage('Invalid Reservation ID format'),

    body('payment_id')
      .notEmpty()
      .withMessage('Payment ID is required')
      .isUUID()
      .withMessage('Invalid Payment ID format'),
  ],
};

module.exports = validators;
