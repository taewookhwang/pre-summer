const dashboardService = require('../services/dashboardService');
const logger = require('../../../../Shared/logger');

/**
 * Controller for handling dashboard-related requests
 */
const dashboardController = {
  /**
   * Get dashboard statistics
   */
  getDashboardStats: async (req, res) => {
    try {
      const filters = {
        startDate: req.query.startDate,
        endDate: req.query.endDate,
      };

      const stats = await dashboardService.getDashboardStats(filters);

      // snake_case로 변환
      const formattedStats = {
        user_stats: {
          total: stats.userStats.total,
          consumers: stats.userStats.consumers,
          technicians: stats.userStats.technicians,
          admins: stats.userStats.admins,
          new_users: stats.userStats.newUsers,
        },
        reservation_stats: {
          total: stats.reservationStats.total,
          pending: stats.reservationStats.pending,
          confirmed: stats.reservationStats.confirmed,
          in_progress: stats.reservationStats.inProgress,
          completed: stats.reservationStats.completed,
          cancelled: stats.reservationStats.cancelled,
          daily_stats: stats.reservationStats.dailyStats,
        },
        job_stats: {
          total: stats.jobStats.total,
          assigned: stats.jobStats.assigned,
          en_route: stats.jobStats.enRoute,
          in_progress: stats.jobStats.inProgress,
          completed: stats.jobStats.completed,
          cancelled: stats.jobStats.cancelled,
          average_completion_time: stats.jobStats.averageCompletionTime,
          daily_stats: stats.jobStats.dailyStats,
        },
        earnings_stats: {
          total_earnings: stats.earningsStats.totalEarnings,
          avg_job_value: stats.earningsStats.avgJobValue,
          daily_earnings: stats.earningsStats.dailyEarnings,
          weekly_earnings: stats.earningsStats.weeklyEarnings,
          monthly_earnings: stats.earningsStats.monthlyEarnings,
        },
        period: {
          start_date: stats.period.startDate,
          end_date: stats.period.endDate,
        },
      };

      return res.status(200).json({
        success: true,
        dashboard_stats: formattedStats,
      });
    } catch (error) {
      logger.error('Error in getDashboardStats controller:', error);
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch dashboard statistics',
          details: error.message,
        },
      });
    }
  },

  /**
   * Get service performance metrics
   */
  getServicePerformance: async (req, res) => {
    try {
      const filters = {
        startDate: req.query.startDate,
        endDate: req.query.endDate,
      };

      const performance = await dashboardService.getServicePerformance(filters);

      // snake_case로 변환
      const formattedPerformance = {
        services: performance.services.map((service) => ({
          id: service.id,
          name: service.name,
          description: service.description,
          price: service.price,
          reservation_count: service.reservationCount,
          revenue: service.revenue,
          average_rating: service.averageRating,
          is_active: service.isActive,
        })),
        most_popular: performance.mostPopular
          ? {
              id: performance.mostPopular.id,
              name: performance.mostPopular.name,
              reservation_count: performance.mostPopular.reservationCount,
            }
          : null,
        least_popular: performance.leastPopular
          ? {
              id: performance.leastPopular.id,
              name: performance.leastPopular.name,
              reservation_count: performance.leastPopular.reservationCount,
            }
          : null,
        highest_revenue: performance.highestRevenue
          ? {
              id: performance.highestRevenue.id,
              name: performance.highestRevenue.name,
              revenue: performance.highestRevenue.revenue,
            }
          : null,
      };

      return res.status(200).json({
        success: true,
        service_performance: formattedPerformance,
      });
    } catch (error) {
      logger.error('Error in getServicePerformance controller:', error);
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch service performance metrics',
          details: error.message,
        },
      });
    }
  },
};

module.exports = dashboardController;
