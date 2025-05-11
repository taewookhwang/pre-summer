const technicianService = require('../services/technicianService');
const logger = require('../../../../Shared/logger');

/**
 * Controller for handling earnings-related requests
 */
const earningsController = {
  /**
   * Get technician's earnings
   */
  getTechnicianEarnings: async (req, res) => {
    try {
      const technicianId = req.user.id; // Assuming auth middleware sets the user

      // Parse filter parameters
      const filters = {};

      if (req.query.startDate) {
        filters.startDate = req.query.startDate;
      }

      if (req.query.endDate) {
        filters.endDate = req.query.endDate;
      }

      const earnings = await technicianService.getTechnicianEarnings(technicianId, filters);

      // 응답 형식 변경: snake_case 사용
      const formattedEarnings = {
        total_earnings: earnings.totalEarnings,
        completed_jobs: earnings.completedJobs,
        daily_earnings: earnings.dailyEarnings,
        weekly_earnings: earnings.weeklyEarnings,
        monthly_earnings: earnings.monthlyEarnings,
        jobs: earnings.jobs.map((job) => ({
          id: job.id,
          end_time: job.endTime,
          earnings: job.earnings,
        })),
      };

      return res.status(200).json({
        success: true,
        earnings: formattedEarnings,
      });
    } catch (error) {
      logger.error('Error in getTechnicianEarnings controller:', error);
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch earnings',
          details: error.message,
        },
      });
    }
  },
};

module.exports = earningsController;
