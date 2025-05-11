const consumerService = require('../services/consumerService');
const { validationResult } = require('express-validator');

/**
 * Controller for handling reservation-related requests
 */
const reservationController = {
  /**
   * Create a new reservation
   */
  createReservation: async (req, res) => {
    try {
      // Validate request data
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

      const userId = req.user.id; // Assuming auth middleware sets the user

      // 요청 데이터를 새 모델 형식에 맞게 매핑
      const reservationData = {
        userId,
        serviceId: req.body.service_id,
        scheduledTime: new Date(req.body.scheduled_time),
        address: {
          street: req.body.address.street,
          detail: req.body.address.detail,
          postalCode: req.body.address.postal_code,
          coordinates: req.body.address.coordinates,
        },
        specialInstructions: req.body.special_instructions || null,
        serviceOptions: req.body.service_options || [],
        customFields: req.body.custom_fields || {},
      };

      const reservation = await consumerService.createReservation(reservationData);

      // 응답 형식 변경: snake_case 사용하고 새로운 필드 추가
      // iOS 앱 호환을 위한 필드 추가 (date_time, reservation_date, total_price)
      const formattedReservation = {
        id: reservation.id,
        user_id: reservation.userId,
        service_id: reservation.serviceId,
        technician_id: reservation.technicianId,
        scheduled_time: reservation.scheduledTime,
        // iOS 앱 호환용 필드들
        date_time: reservation.scheduledTime,
        reservation_date: reservation.scheduledTime,
        status: reservation.status,
        current_step: reservation.currentStep,
        address: {
          street: reservation.street,
          detail: reservation.detail,
          postal_code: reservation.postalCode,
          coordinates: {
            latitude: reservation.latitude,
            longitude: reservation.longitude,
          },
        },
        special_instructions: reservation.specialInstructions,
        service_options: reservation.serviceOptions,
        custom_fields: reservation.customFields,
        estimated_price: reservation.estimatedPrice,
        // iOS 앱 호환용 필드
        total_price: reservation.estimatedPrice,
        estimated_duration: reservation.estimatedDuration,
        payment_status: reservation.paymentStatus,
        created_at: reservation.createdAt,
        updated_at: reservation.updatedAt,
      };

      return res.status(201).json({
        success: true,
        reservation: formattedReservation,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to create reservation',
          details: error.message,
        },
      });
    }
  },

  /**
   * Get user's reservations with pagination
   */
  getUserReservations: async (req, res) => {
    try {
      const userId = req.user.id; // Assuming auth middleware sets the user

      // Parse filter parameters
      const filters = {};

      if (req.query.status) {
        filters.status = req.query.status;
      }

      if (req.query.start_date) {
        filters.startDate = new Date(req.query.start_date);
      }

      if (req.query.end_date) {
        filters.endDate = new Date(req.query.end_date);
      }

      // Extract pagination parameters
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;

      // Get paginated reservations
      const result = await consumerService.getUserReservations(userId, filters, page, limit);

      // 응답 형식 변경: 필드명 snake_case로 변환하고 새 모델에 맞게 필드 추가
      const formattedReservations = result.reservations.map((reservation) => {
        const formatted = {
          id: reservation.id,
          user_id: reservation.userId,
          service_id: reservation.serviceId,
          technician_id: reservation.technicianId,
          scheduled_time: reservation.scheduledTime,
          status: reservation.status,
          current_step: reservation.currentStep,
          address: {
            street: reservation.street,
            detail: reservation.detail,
            postal_code: reservation.postalCode,
            coordinates: {
              latitude: reservation.latitude,
              longitude: reservation.longitude,
            },
          },
          special_instructions: reservation.specialInstructions,
          service_options: reservation.serviceOptions,
          custom_fields: reservation.customFields,
          estimated_price: reservation.estimatedPrice,
          estimated_duration: reservation.estimatedDuration,
          payment_status: reservation.paymentStatus,
          created_at: reservation.createdAt,
          updated_at: reservation.updatedAt,
        };

        // 서비스 정보가 포함된 경우 서비스 정보도 변환
        if (reservation.Service) {
          formatted.service = {
            id: reservation.Service.id,
            name: reservation.Service.name,
            short_description: reservation.Service.shortDescription,
            description: reservation.Service.description,
            base_price: reservation.Service.basePrice,
            duration: reservation.Service.duration,
            category_id: reservation.Service.categoryId,
            subcategory_id: reservation.Service.subcategoryId,
            is_active: reservation.Service.isActive,
          };
        }

        return formatted;
      });

      return res.status(200).json({
        success: true,
        reservations: formattedReservations,
        pagination: result.pagination,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch reservations',
          details: error.message,
        },
      });
    }
  },

  /**
   * Get reservation by ID
   */
  getReservationById: async (req, res) => {
    try {
      const { reservationId } = req.params;
      const userId = req.user.id; // Assuming auth middleware sets the user

      const reservation = await consumerService.getReservationById(reservationId, userId);

      // 응답 형식 변경: snake_case 사용하고 새 모델에 맞게 필드 추가
      const formattedReservation = {
        id: reservation.id,
        user_id: reservation.userId,
        service_id: reservation.serviceId,
        technician_id: reservation.technicianId,
        scheduled_time: reservation.scheduledTime,
        status: reservation.status,
        current_step: reservation.currentStep,
        address: {
          street: reservation.street,
          detail: reservation.detail,
          postal_code: reservation.postalCode,
          coordinates: {
            latitude: reservation.latitude,
            longitude: reservation.longitude,
          },
        },
        special_instructions: reservation.specialInstructions,
        service_options: reservation.serviceOptions,
        custom_fields: reservation.customFields,
        estimated_price: reservation.estimatedPrice,
        estimated_duration: reservation.estimatedDuration,
        payment_status: reservation.paymentStatus,
        created_at: reservation.createdAt,
        updated_at: reservation.updatedAt,
      };

      // 서비스 정보가 포함된 경우 서비스 정보도 변환
      if (reservation.Service) {
        formattedReservation.service = {
          id: reservation.Service.id,
          name: reservation.Service.name,
          short_description: reservation.Service.shortDescription,
          description: reservation.Service.description,
          base_price: reservation.Service.basePrice,
          duration: reservation.Service.duration,
          category_id: reservation.Service.categoryId,
          subcategory_id: reservation.Service.subcategoryId,
          is_active: reservation.Service.isActive,
        };
      }

      return res.status(200).json({
        success: true,
        reservation: formattedReservation,
      });
    } catch (error) {
      return res.status(error.message === 'Reservation not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to fetch reservation',
          details: error.message,
        },
      });
    }
  },

  /**
   * Update reservation status
   */
  updateReservationStatus: async (req, res) => {
    try {
      // Validate request data
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

      const { reservationId } = req.params;
      const userId = req.user.id; // Assuming auth middleware sets the user
      const { status, reason } = req.body;

      // 이유가 제공된 경우 함께 전달
      const updateOptions = { reason };

      const updatedReservation = await consumerService.updateReservationStatus(
        reservationId,
        userId,
        status,
        updateOptions,
      );

      // 응답 형식 변경: snake_case 사용하고 새 모델에 맞게 필드 추가
      const formattedReservation = {
        id: updatedReservation.id,
        user_id: updatedReservation.userId,
        service_id: updatedReservation.serviceId,
        technician_id: updatedReservation.technicianId,
        scheduled_time: updatedReservation.scheduledTime,
        status: updatedReservation.status,
        current_step: updatedReservation.currentStep,
        address: {
          street: updatedReservation.street,
          detail: updatedReservation.detail,
          postal_code: updatedReservation.postalCode,
          coordinates: {
            latitude: updatedReservation.latitude,
            longitude: updatedReservation.longitude,
          },
        },
        special_instructions: updatedReservation.specialInstructions,
        service_options: updatedReservation.serviceOptions,
        custom_fields: updatedReservation.customFields,
        estimated_price: updatedReservation.estimatedPrice,
        estimated_duration: updatedReservation.estimatedDuration,
        payment_status: updatedReservation.paymentStatus,
        created_at: updatedReservation.createdAt,
        updated_at: updatedReservation.updatedAt,
      };

      // 서비스 정보가 포함된 경우 서비스 정보도 변환
      if (updatedReservation.Service) {
        formattedReservation.service = {
          id: updatedReservation.Service.id,
          name: updatedReservation.Service.name,
          short_description: updatedReservation.Service.shortDescription,
          description: updatedReservation.Service.description,
          base_price: updatedReservation.Service.basePrice,
          duration: updatedReservation.Service.duration,
          category_id: updatedReservation.Service.categoryId,
          subcategory_id: updatedReservation.Service.subcategoryId,
          is_active: updatedReservation.Service.isActive,
        };
      }

      return res.status(200).json({
        success: true,
        reservation: formattedReservation,
      });
    } catch (error) {
      return res.status(error.message === 'Reservation not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to update reservation status',
          details: error.message,
        },
      });
    }
  },

  /**
   * Get reservation status details (including real-time info)
   */
  getReservationStatus: async (req, res) => {
    try {
      const { reservationId } = req.params;
      const userId = req.user.id; // Assuming auth middleware sets the user

      // First verify that the reservation belongs to this user
      await consumerService.getReservationById(reservationId, userId);

      // Get reservation status details
      const statusDetails = await consumerService.getReservationStatus(reservationId);

      return res.status(200).json({
        success: true,
        status: statusDetails,
      });
    } catch (error) {
      return res.status(error.message === 'Reservation not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to fetch reservation status',
          details: error.message,
        },
      });
    }
  },
};

module.exports = reservationController;
