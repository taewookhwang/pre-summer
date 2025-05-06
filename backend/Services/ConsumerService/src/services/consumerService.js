const Service = require('../models/Service');
const Reservation = require('../models/Reservation');
const { Op } = require('sequelize');
const logger = require('../../../../Shared/logger');

/**
 * Service to handle consumer-related operations
 */
class ConsumerService {
  /**
   * Get list of available services
   * @param {Object} filters - Optional filters for services
   * @returns {Promise<Array>} List of services
   */
  async getServices(filters = {}) {
    try {
      const whereClause = { isActive: true };
      
      if (filters.category) {
        whereClause.category = filters.category;
      }
      
      if (filters.minPrice && filters.maxPrice) {
        whereClause.price = {
          [Op.between]: [filters.minPrice, filters.maxPrice]
        };
      } else if (filters.minPrice) {
        whereClause.price = {
          [Op.gte]: filters.minPrice
        };
      } else if (filters.maxPrice) {
        whereClause.price = {
          [Op.lte]: filters.maxPrice
        };
      }
      
      const services = await Service.findAll({
        where: whereClause,
        order: [['name', 'ASC']]
      });
      
      return services;
    } catch (error) {
      logger.error('Error fetching services:', error);
      throw error;
    }
  }
  
  /**
   * Get service by id
   * @param {String} serviceId - The service ID
   * @returns {Promise<Object>} Service object
   */
  async getServiceById(serviceId) {
    try {
      const service = await Service.findByPk(serviceId);
      
      if (!service) {
        throw new Error('Service not found');
      }
      
      return service;
    } catch (error) {
      logger.error(`Error fetching service with id ${serviceId}:`, error);
      throw error;
    }
  }
  
  /**
   * Create a new reservation
   * @param {Object} reservationData - Reservation details
   * @returns {Promise<Object>} Created reservation
   */
  async createReservation(reservationData) {
    try {
      // Get the service to calculate the price
      const service = await this.getServiceById(reservationData.serviceId);
      
      // Create the reservation with the calculated price
      const reservation = await Reservation.create({
        ...reservationData,
        totalPrice: service.price
      });
      
      return reservation;
    } catch (error) {
      logger.error('Error creating reservation:', error);
      throw error;
    }
  }
  
  /**
   * Get reservations for a consumer
   * @param {Number} userId - The user ID
   * @param {Object} filters - Optional filters
   * @returns {Promise<Array>} List of reservations
   */
  async getUserReservations(userId, filters = {}) {
    try {
      const whereClause = { userId };
      
      // Filter by status if provided
      if (filters.status) {
        whereClause.status = filters.status;
      }
      
      // Filter by date range if provided
      if (filters.startDate && filters.endDate) {
        whereClause.reservationDate = {
          [Op.between]: [filters.startDate, filters.endDate]
        };
      } else if (filters.startDate) {
        whereClause.reservationDate = {
          [Op.gte]: filters.startDate
        };
      } else if (filters.endDate) {
        whereClause.reservationDate = {
          [Op.lte]: filters.endDate
        };
      }
      
      const reservations = await Reservation.findAll({
        where: whereClause,
        include: [{
          model: Service,
          attributes: ['id', 'name', 'description', 'price', 'duration', 'category']
        }],
        order: [['reservationDate', 'DESC']]
      });
      
      return reservations;
    } catch (error) {
      logger.error(`Error fetching reservations for user ${userId}:`, error);
      throw error;
    }
  }
  
  /**
   * Get reservation by id
   * @param {String} reservationId - The reservation ID
   * @param {Number} userId - The user ID (for security check)
   * @returns {Promise<Object>} Reservation object
   */
  async getReservationById(reservationId, userId) {
    try {
      const reservation = await Reservation.findOne({
        where: {
          id: reservationId,
          userId
        },
        include: [{
          model: Service,
          attributes: ['id', 'name', 'description', 'price', 'duration', 'category']
        }]
      });
      
      if (!reservation) {
        throw new Error('Reservation not found');
      }
      
      return reservation;
    } catch (error) {
      logger.error(`Error fetching reservation with id ${reservationId}:`, error);
      throw error;
    }
  }
  
  /**
   * Update reservation status
   * @param {String} reservationId - The reservation ID
   * @param {Number} userId - The user ID (for security check)
   * @param {String} status - New status
   * @returns {Promise<Object>} Updated reservation
   */
  async updateReservationStatus(reservationId, userId, status) {
    try {
      const allowedStatuses = ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'];
      
      if (!allowedStatuses.includes(status)) {
        throw new Error('Invalid status value');
      }
      
      const reservation = await this.getReservationById(reservationId, userId);
      
      // Check if status change is valid
      if (status === 'cancelled' && ['completed', 'in_progress'].includes(reservation.status)) {
        throw new Error('Cannot cancel a reservation that is in progress or completed');
      }
      
      reservation.status = status;
      await reservation.save();
      
      return reservation;
    } catch (error) {
      logger.error(`Error updating reservation status:`, error);
      throw error;
    }
  }
}

module.exports = new ConsumerService();