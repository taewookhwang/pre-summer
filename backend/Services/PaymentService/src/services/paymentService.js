const Payment = require('../models/Payment');
const logger = require('../../../../Shared/logger');
const { sequelize } = require('../../../../Shared/database');
const axios = require('axios');

/**
 * 토스페이먼츠 API 설정
 * 실제 구현 시에는 환경 변수에서 가져오는 것이 좋습니다.
 */
const TOSS_API_URL = 'https://api.tosspayments.com/v1';
const TOSS_SECRET_KEY = process.env.TOSS_SECRET_KEY || 'test_sk_sample';
const TOSS_CLIENT_KEY = process.env.TOSS_CLIENT_KEY || 'test_ck_sample';

// Base64 인코딩을 위한 헬퍼 함수
const getAuthorizationHeader = () => {
  return `Basic ${Buffer.from(`${TOSS_SECRET_KEY}:`).toString('base64')}`;
};

/**
 * 결제 서비스
 */
class PaymentService {
  /**
   * 결제 정보를 생성합니다.
   * @param {Object} paymentData - 결제 데이터
   * @returns {Promise<Object>} 생성된 결제 정보
   */
  async createPayment(paymentData) {
    try {
      // 트랜잭션 시작
      return await sequelize.transaction(async (transaction) => {
        // 결제 정보 기본 데이터 생성
        const payment = await Payment.create(
          {
            reservationId: paymentData.reservation_id,
            userId: paymentData.user_id,
            amount: paymentData.amount,
            paymentMethod: paymentData.payment_method,
            status: 'pending',
          },
          { transaction },
        );

        // 토스페이먼츠 결제 요청 생성
        const paymentRequestData = {
          amount: Number(paymentData.amount),
          orderId: payment.id,
          orderName: `홈클리닝 서비스 예약 (${payment.reservationId})`,
          successUrl: `${paymentData.success_url || 'https://api.homecleaning.com/v1/payments/success'}?payment_id=${payment.id}`,
          failUrl: `${paymentData.fail_url || 'https://api.homecleaning.com/v1/payments/fail'}?payment_id=${payment.id}`,
          customerEmail: paymentData.customer_email,
          customerName: paymentData.customer_name,
        };

        try {
          // 토스페이먼츠 API 호출
          const response = await axios.post(
            `${TOSS_API_URL}/payments/${paymentData.payment_method}/payments`,
            paymentRequestData,
            {
              headers: {
                Authorization: getAuthorizationHeader(),
                'Content-Type': 'application/json',
              },
            },
          );

          // 응답 데이터 업데이트
          payment.paymentUrl = response.data.url;
          payment.paymentDetails = response.data;
          await payment.save({ transaction });

          return payment;
        } catch (apiError) {
          // API 오류 처리
          logger.error('Toss Payments API error:', apiError.response?.data || apiError.message);
          payment.status = 'failed';
          payment.paymentDetails = apiError.response?.data || { error: apiError.message };
          await payment.save({ transaction });
          throw new Error('Payment provider API error');
        }
      });
    } catch (error) {
      logger.error('Error creating payment:', error);
      throw error;
    }
  }

  /**
   * 결제 정보를 조회합니다.
   * @param {String} paymentId - 결제 ID
   * @returns {Promise<Object>} 결제 정보
   */
  async getPayment(paymentId) {
    try {
      const payment = await Payment.findByPk(paymentId);

      if (!payment) {
        throw new Error('Payment not found');
      }

      return payment;
    } catch (error) {
      logger.error(`Error fetching payment with id ${paymentId}:`, error);
      throw error;
    }
  }

  /**
   * 결제를 확인합니다.
   * @param {String} paymentId - 결제 ID
   * @param {Object} confirmData - 확인 데이터
   * @returns {Promise<Object>} 업데이트된 결제 정보
   */
  async confirmPayment(paymentId, confirmData) {
    try {
      const payment = await this.getPayment(paymentId);

      // 이미 처리된 결제인지 확인
      if (payment.status !== 'pending') {
        throw new Error(`Payment already processed with status: ${payment.status}`);
      }

      // 트랜잭션 시작
      return await sequelize.transaction(async (transaction) => {
        try {
          // 토스페이먼츠 결제 승인 API 호출
          const response = await axios.post(
            `${TOSS_API_URL}/payments/${confirmData.payment_key}/confirm`,
            {
              orderId: payment.id,
              amount: Number(payment.amount),
            },
            {
              headers: {
                Authorization: getAuthorizationHeader(),
                'Content-Type': 'application/json',
              },
            },
          );

          // 결제 정보 업데이트
          payment.status = 'paid';
          payment.transactionId = confirmData.payment_key;
          payment.paymentDetails = {
            ...payment.paymentDetails,
            confirmation: response.data,
          };
          await payment.save({ transaction });

          return payment;
        } catch (apiError) {
          // API 오류 처리
          logger.error(
            'Toss Payments confirmation API error:',
            apiError.response?.data || apiError.message,
          );
          payment.status = 'failed';
          payment.paymentDetails = {
            ...payment.paymentDetails,
            confirmationError: apiError.response?.data || { error: apiError.message },
          };
          await payment.save({ transaction });
          throw new Error('Payment confirmation failed');
        }
      });
    } catch (error) {
      logger.error(`Error confirming payment ${paymentId}:`, error);
      throw error;
    }
  }

  /**
   * 결제를 취소합니다.
   * @param {String} paymentId - 결제 ID
   * @param {Object} cancelData - 취소 데이터
   * @returns {Promise<Object>} 업데이트된 결제 정보
   */
  async cancelPayment(paymentId, cancelData) {
    try {
      const payment = await this.getPayment(paymentId);

      // 취소 가능한 상태인지 확인
      if (payment.status !== 'paid') {
        throw new Error(`Cannot cancel payment with status: ${payment.status}`);
      }

      // 트랜잭션 시작
      return await sequelize.transaction(async (transaction) => {
        try {
          // 토스페이먼츠 결제 취소 API 호출
          const response = await axios.post(
            `${TOSS_API_URL}/payments/${payment.transactionId}/cancel`,
            {
              cancelReason: cancelData.reason,
            },
            {
              headers: {
                Authorization: getAuthorizationHeader(),
                'Content-Type': 'application/json',
              },
            },
          );

          // 결제 정보 업데이트
          payment.status = 'cancelled';
          payment.paymentDetails = {
            ...payment.paymentDetails,
            cancellation: response.data,
          };
          await payment.save({ transaction });

          return payment;
        } catch (apiError) {
          // API 오류 처리
          logger.error(
            'Toss Payments cancellation API error:',
            apiError.response?.data || apiError.message,
          );
          throw new Error('Payment cancellation failed');
        }
      });
    } catch (error) {
      logger.error(`Error cancelling payment ${paymentId}:`, error);
      throw error;
    }
  }

  /**
   * 예약에 결제 정보를 연결합니다.
   * @param {String} reservationId - 예약 ID
   * @param {String} paymentId - 결제 ID
   * @returns {Promise<Object>} 연결된 예약 및 결제 정보
   */
  async linkPaymentToReservation(reservationId, paymentId) {
    try {
      // 결제 정보 확인
      const payment = await this.getPayment(paymentId);

      // 이미 다른 예약에 연결된 결제인지 확인
      if (payment.reservationId !== reservationId) {
        throw new Error('Payment is already linked to a different reservation');
      }

      // 여기서는 결제 정보가 이미 예약 ID를 가지고 있으므로
      // 추가적인 처리 없이 결과를 반환합니다.
      // 실제 구현에서는 예약 서비스의 API를 호출하여 예약 상태를 업데이트할 수 있습니다.

      return {
        payment_id: payment.id,
        reservation_id: payment.reservationId,
        status: payment.status,
      };
    } catch (error) {
      logger.error(`Error linking payment ${paymentId} to reservation ${reservationId}:`, error);
      throw error;
    }
  }

  /**
   * 웹훅 이벤트를 처리합니다.
   * @param {Object} webhookData - 웹훅 데이터
   * @returns {Promise<Object>} 처리 결과
   */
  async handleWebhook(webhookData) {
    try {
      const { payment } = webhookData;

      // 결제 정보 조회
      const paymentRecord = await Payment.findOne({
        where: { id: payment.orderId },
      });

      if (!paymentRecord) {
        throw new Error(`Payment with order ID ${payment.orderId} not found`);
      }

      // 결제 상태 업데이트
      const status = this.mapTossPaymentStatus(payment.status);
      paymentRecord.status = status;
      paymentRecord.paymentDetails = {
        ...paymentRecord.paymentDetails,
        webhook: webhookData,
      };

      await paymentRecord.save();

      return {
        success: true,
        payment_id: paymentRecord.id,
        status,
      };
    } catch (error) {
      logger.error('Error handling webhook:', error);
      throw error;
    }
  }

  /**
   * 토스페이먼츠 결제 상태를 내부 상태로 매핑합니다.
   * @param {String} tossStatus - 토스페이먼츠 결제 상태
   * @returns {String} 내부 결제 상태
   */
  mapTossPaymentStatus(tossStatus) {
    const statusMap = {
      READY: 'pending',
      IN_PROGRESS: 'pending',
      WAITING_FOR_DEPOSIT: 'pending',
      DONE: 'paid',
      CANCELED: 'cancelled',
      PARTIAL_CANCELED: 'refunded',
      ABORTED: 'failed',
      EXPIRED: 'failed',
    };

    return statusMap[tossStatus] || 'pending';
  }
}

module.exports = new PaymentService();
