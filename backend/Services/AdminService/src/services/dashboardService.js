const axios = require('axios');
const { sequelize } = require('../../../../Shared/database');
const { QueryTypes } = require('sequelize');
const logger = require('../../../../Shared/logger');
require('dotenv').config({ path: '../../../../Infrastructure/.env' });

/**
 * Service to handle admin dashboard operations
 */
class DashboardService {
  /**
   * Get dashboard statistics
   * @param {Object} filters - Optional filters like date range
   * @returns {Promise<Object>} Dashboard statistics
   */
  async getDashboardStats(filters = {}) {
    try {
      // Set date range for filtering
      const startDate = filters.startDate ? new Date(filters.startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
      const endDate = filters.endDate ? new Date(filters.endDate) : new Date();
      
      // Get stats from different services
      const [
        userStats,
        reservationStats,
        jobStats,
        earningsStats
      ] = await Promise.all([
        this.getUserStats(),
        this.getReservationStats(startDate, endDate),
        this.getJobStats(startDate, endDate),
        this.getEarningsStats(startDate, endDate)
      ]);
      
      return {
        userStats,
        reservationStats,
        jobStats,
        earningsStats,
        period: {
          startDate: startDate.toISOString(),
          endDate: endDate.toISOString()
        }
      };
    } catch (error) {
      logger.error('Error fetching dashboard stats:', error);
      throw error;
    }
  }
  
  /**
   * Get user statistics
   * @returns {Promise<Object>} User statistics
   */
  async getUserStats() {
    try {
      // Query to count users by role
      const usersByRole = await sequelize.query(`
        SELECT role, COUNT(*) as count
        FROM users
        GROUP BY role
      `, { type: QueryTypes.SELECT });
      
      // Convert to a more usable format
      const roleStats = {
        total: 0,
        consumers: 0,
        technicians: 0,
        admins: 0
      };
      
      usersByRole.forEach(stat => {
        if (stat.role === 'consumer') roleStats.consumers = parseInt(stat.count);
        else if (stat.role === 'technician') roleStats.technicians = parseInt(stat.count);
        else if (stat.role === 'admin') roleStats.admins = parseInt(stat.count);
        
        roleStats.total += parseInt(stat.count);
      });
      
      // Get new user count in the last 30 days
      const newUsers = await sequelize.query(`
        SELECT COUNT(*) as count
        FROM users
        WHERE created_at >= NOW() - INTERVAL '30 days'
      `, { type: QueryTypes.SELECT });
      
      return {
        ...roleStats,
        newUsers: parseInt(newUsers[0]?.count || 0)
      };
    } catch (error) {
      logger.error('Error fetching user stats:', error);
      return {
        total: 0,
        consumers: 0,
        technicians: 0,
        admins: 0,
        newUsers: 0
      };
    }
  }
  
  /**
   * Get reservation statistics
   * @param {Date} startDate - Start date for period
   * @param {Date} endDate - End date for period
   * @returns {Promise<Object>} Reservation statistics
   */
  async getReservationStats(startDate, endDate) {
    try {
      // Call Consumer Service API to get reservation stats
      const response = await axios.get(
        `${process.env.CONSUMER_SERVICE_URL}/api/admin/stats/reservations`,
        {
          params: {
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString()
          }
        }
      );
      
      if (response.data && response.data.success) {
        return response.data.reservation_stats;
      }
      
      throw new Error('Failed to fetch reservation stats from Consumer Service');
    } catch (error) {
      logger.error('Error fetching reservation stats:', error);
      return {
        total: 0,
        pending: 0,
        confirmed: 0,
        in_progress: 0,
        completed: 0,
        cancelled: 0,
        daily_stats: {}
      };
    }
  }
  
  /**
   * Get job statistics
   * @param {Date} startDate - Start date for period
   * @param {Date} endDate - End date for period
   * @returns {Promise<Object>} Job statistics
   */
  async getJobStats(startDate, endDate) {
    try {
      // Call Technician Service API to get job stats
      const response = await axios.get(
        `${process.env.TECHNICIAN_SERVICE_URL}/api/admin/stats/jobs`,
        {
          params: {
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString()
          }
        }
      );
      
      if (response.data && response.data.success) {
        return response.data.job_stats;
      }
      
      throw new Error('Failed to fetch job stats from Technician Service');
    } catch (error) {
      logger.error('Error fetching job stats:', error);
      return {
        total: 0,
        assigned: 0,
        en_route: 0,
        in_progress: 0,
        completed: 0,
        cancelled: 0,
        average_completion_time: 0,
        daily_stats: {}
      };
    }
  }
  
  /**
   * Get earnings statistics
   * @param {Date} startDate - Start date for period
   * @param {Date} endDate - End date for period
   * @returns {Promise<Object>} Earnings statistics
   */
  async getEarningsStats(startDate, endDate) {
    try {
      // Call Technician Service API to get earnings stats
      const response = await axios.get(
        `${process.env.TECHNICIAN_SERVICE_URL}/api/admin/stats/earnings`,
        {
          params: {
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString()
          }
        }
      );
      
      if (response.data && response.data.success) {
        return response.data.earnings_stats;
      }
      
      throw new Error('Failed to fetch earnings stats from Technician Service');
    } catch (error) {
      logger.error('Error fetching earnings stats:', error);
      return {
        total_earnings: 0,
        avg_job_value: 0,
        daily_earnings: {},
        weekly_earnings: {},
        monthly_earnings: {}
      };
    }
  }
  
  /**
   * Get service performance metrics
   * @param {Object} filters - Optional filters like date range
   * @returns {Promise<Object>} Service performance metrics
   */
  async getServicePerformance(filters = {}) {
    try {
      // Set date range for filtering
      const startDate = filters.startDate ? new Date(filters.startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
      const endDate = filters.endDate ? new Date(filters.endDate) : new Date();
      
      // Call Consumer Service API to get service performance metrics
      const response = await axios.get(
        `${process.env.CONSUMER_SERVICE_URL}/api/admin/stats/services`,
        {
          params: {
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString()
          }
        }
      );
      
      if (response.data && response.data.success) {
        return response.data.service_performance;
      }
      
      throw new Error('Failed to fetch service performance metrics');
    } catch (error) {
      logger.error('Error fetching service performance:', error);
      return {
        services: [],
        mostPopular: null,
        leastPopular: null,
        highestRevenue: null
      };
    }
  }
}

module.exports = new DashboardService();