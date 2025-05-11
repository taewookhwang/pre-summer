const paymentService = require('../services/paymentService');
const { validationResult } = require('express-validator');

/**
 * 결제 컨트롤러
 */
const paymentController = {
  /**
   * 결제 생성
   */
  createPayment: async (req, res) => {
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

      const userId = req.user.id; // auth 미들웨어에서 설정

      // 결제 데이터 준비
      const paymentData = {
        user_id: userId,
        reservation_id: req.body.reservation_id,
        amount: req.body.amount,
        payment_method: req.body.payment_method,
        success_url: req.body.success_url,
        fail_url: req.body.fail_url,
        customer_email: req.user.email,
        customer_name: req.user.name,
      };

      // 결제 생성
      const payment = await paymentService.createPayment(paymentData);

      // 응답 포맷팅
      const response = formatPaymentResponse(payment);

      return res.status(201).json({
        success: true,
        payment: response,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to create payment',
          details: error.message,
        },
      });
    }
  },

  /**
   * 결제 정보 조회
   */
  getPayment: async (req, res) => {
    try {
      const { paymentId } = req.params;

      // 결제 정보 조회
      const payment = await paymentService.getPayment(paymentId);

      // 액세스 권한 확인 (결제 생성자만 조회 가능)
      if (payment.userId !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          error: {
            message: 'Access denied',
          },
        });
      }

      // 응답 포맷팅
      const response = formatPaymentResponse(payment);

      return res.status(200).json({
        success: true,
        payment: response,
      });
    } catch (error) {
      return res.status(error.message === 'Payment not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to fetch payment',
          details: error.message,
        },
      });
    }
  },

  /**
   * 결제 확인
   */
  confirmPayment: async (req, res) => {
    try {
      const { paymentId } = req.params;

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

      // 결제 확인 데이터
      const confirmData = {
        payment_status: req.body.payment_status,
        payment_key: req.body.transaction_id,
      };

      // 결제 확인
      const payment = await paymentService.confirmPayment(paymentId, confirmData);

      // 응답 포맷팅
      const response = formatPaymentResponse(payment);

      return res.status(200).json({
        success: true,
        payment: response,
      });
    } catch (error) {
      return res.status(error.message === 'Payment not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to confirm payment',
          details: error.message,
        },
      });
    }
  },

  /**
   * 결제 취소
   */
  cancelPayment: async (req, res) => {
    try {
      const { paymentId } = req.params;

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

      // 결제 정보 조회
      const payment = await paymentService.getPayment(paymentId);

      // 액세스 권한 확인 (결제 생성자만 취소 가능)
      if (payment.userId !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          error: {
            message: 'Access denied',
          },
        });
      }

      // 결제 취소 데이터
      const cancelData = {
        reason: req.body.reason,
      };

      // 결제 취소
      const cancelledPayment = await paymentService.cancelPayment(paymentId, cancelData);

      // 응답 포맷팅
      const response = formatPaymentResponse(cancelledPayment);

      return res.status(200).json({
        success: true,
        payment: response,
      });
    } catch (error) {
      return res.status(error.message === 'Payment not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to cancel payment',
          details: error.message,
        },
      });
    }
  },

  /**
   * 예약에 결제 정보 연결
   */
  linkPaymentToReservation: async (req, res) => {
    try {
      const { reservationId } = req.params;

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

      // 결제 ID 가져오기
      const { payment_id } = req.body;

      // 예약에 결제 정보 연결
      const result = await paymentService.linkPaymentToReservation(reservationId, payment_id);

      return res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: error.message || 'Failed to link payment to reservation',
          details: error.message,
        },
      });
    }
  },

  /**
   * 웹훅 핸들러
   */
  handleWebhook: async (req, res) => {
    try {
      // 웹훅 데이터
      const webhookData = req.body;

      // 웹훅 처리
      const result = await paymentService.handleWebhook(webhookData);

      return res.status(200).json({
        success: true,
        result,
      });
    } catch (error) {
      // 웹훅은 외부 서비스에서 호출하므로 로그만 기록하고 성공 응답을 반환
      console.error('Error handling webhook:', error);

      return res.status(200).json({
        success: false,
        error: error.message,
      });
    }
  },
};

/**
 * 결제 응답 포맷팅
 * @param {Object} payment - 결제 객체
 * @returns {Object} 포맷팅된 응답
 */
function formatPaymentResponse(payment) {
  return {
    id: payment.id,
    reservation_id: payment.reservationId,
    user_id: payment.userId,
    amount: payment.amount,
    payment_method: payment.paymentMethod,
    status: payment.status,
    payment_url: payment.paymentUrl,
    transaction_id: payment.transactionId,
    created_at: payment.createdAt,
    updated_at: payment.updatedAt,
  };
}

module.exports = paymentController;
