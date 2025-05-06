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
            details: errors.array().map(err => ({
              field: err.param,
              message: err.msg
            }))
          }
        });
      }
      
      const userId = req.user.id; // Assuming auth middleware sets the user
      
      const reservationData = {
        userId,
        serviceId: req.body.serviceId,
        reservationDate: new Date(req.body.reservationDate),
        address: req.body.address,
        specialInstructions: req.body.specialInstructions || null
      };
      
      const reservation = await consumerService.createReservation(reservationData);
      
      // 응답 형식 변경: snake_case 사용
      const formattedReservation = {
        id: reservation.id,
        user_id: reservation.userId,
        service_id: reservation.serviceId,
        technician_id: reservation.technicianId,
        reservation_date: reservation.reservationDate,
        status: reservation.status,
        address: reservation.address,
        special_instructions: reservation.specialInstructions,
        total_price: reservation.totalPrice,
        payment_status: reservation.paymentStatus,
        created_at: reservation.createdAt,
        updated_at: reservation.updatedAt
      };
      
      return res.status(201).json({
        success: true,
        reservation: formattedReservation
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to create reservation',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Get user's reservations
   */
  getUserReservations: async (req, res) => {
    try {
      const userId = req.user.id; // Assuming auth middleware sets the user
      
      // Parse filter parameters
      const filters = {};
      
      if (req.query.status) {
        filters.status = req.query.status;
      }
      
      if (req.query.startDate) {
        filters.startDate = new Date(req.query.startDate);
      }
      
      if (req.query.endDate) {
        filters.endDate = new Date(req.query.endDate);
      }
      
      const reservations = await consumerService.getUserReservations(userId, filters);
      
      // 응답 형식 변경: 필드명 snake_case로 변환
      const formattedReservations = reservations.map(reservation => {
        const formatted = {
          id: reservation.id,
          user_id: reservation.userId,
          service_id: reservation.serviceId,
          technician_id: reservation.technicianId,
          reservation_date: reservation.reservationDate,
          status: reservation.status,
          address: reservation.address,
          special_instructions: reservation.specialInstructions,
          total_price: reservation.totalPrice,
          payment_status: reservation.paymentStatus,
          created_at: reservation.createdAt,
          updated_at: reservation.updatedAt
        };
        
        // 서비스 정보가 포함된 경우 서비스 정보도 변환
        if (reservation.Service) {
          formatted.service = {
            id: reservation.Service.id,
            name: reservation.Service.name,
            description: reservation.Service.description,
            price: reservation.Service.price,
            duration: reservation.Service.duration,
            category: reservation.Service.category,
            is_active: reservation.Service.isActive
          };
        }
        
        return formatted;
      });
      
      return res.status(200).json({
        success: true,
        reservations: formattedReservations
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch reservations',
          details: error.message
        }
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
      
      // 응답 형식 변경: snake_case 사용
      const formattedReservation = {
        id: reservation.id,
        user_id: reservation.userId,
        service_id: reservation.serviceId,
        technician_id: reservation.technicianId,
        reservation_date: reservation.reservationDate,
        status: reservation.status,
        address: reservation.address,
        special_instructions: reservation.specialInstructions,
        total_price: reservation.totalPrice,
        payment_status: reservation.paymentStatus,
        created_at: reservation.createdAt,
        updated_at: reservation.updatedAt
      };
      
      // 서비스 정보가 포함된 경우 서비스 정보도 변환
      if (reservation.Service) {
        formattedReservation.service = {
          id: reservation.Service.id,
          name: reservation.Service.name,
          description: reservation.Service.description,
          price: reservation.Service.price,
          duration: reservation.Service.duration,
          category: reservation.Service.category,
          is_active: reservation.Service.isActive
        };
      }
      
      return res.status(200).json({
        success: true,
        reservation: formattedReservation
      });
    } catch (error) {
      return res.status(error.message === 'Reservation not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to fetch reservation',
          details: error.message
        }
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
            details: errors.array().map(err => ({
              field: err.param,
              message: err.msg
            }))
          }
        });
      }
      
      const { reservationId } = req.params;
      const userId = req.user.id; // Assuming auth middleware sets the user
      const { status } = req.body;
      
      const updatedReservation = await consumerService.updateReservationStatus(
        reservationId,
        userId,
        status
      );
      
      // 응답 형식 변경: snake_case 사용
      const formattedReservation = {
        id: updatedReservation.id,
        user_id: updatedReservation.userId,
        service_id: updatedReservation.serviceId,
        technician_id: updatedReservation.technicianId,
        reservation_date: updatedReservation.reservationDate,
        status: updatedReservation.status,
        address: updatedReservation.address,
        special_instructions: updatedReservation.specialInstructions,
        total_price: updatedReservation.totalPrice,
        payment_status: updatedReservation.paymentStatus,
        created_at: updatedReservation.createdAt,
        updated_at: updatedReservation.updatedAt
      };
      
      // 서비스 정보가 포함된 경우 서비스 정보도 변환
      if (updatedReservation.Service) {
        formattedReservation.service = {
          id: updatedReservation.Service.id,
          name: updatedReservation.Service.name,
          description: updatedReservation.Service.description,
          price: updatedReservation.Service.price,
          duration: updatedReservation.Service.duration,
          category: updatedReservation.Service.category,
          is_active: updatedReservation.Service.isActive
        };
      }
      
      return res.status(200).json({
        success: true,
        reservation: formattedReservation
      });
    } catch (error) {
      return res.status(error.message === 'Reservation not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to update reservation status',
          details: error.message
        }
      });
    }
  }
};

module.exports = reservationController;