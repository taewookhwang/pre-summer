const Job = require('../models/Job');
const { Op } = require('sequelize');
const axios = require('axios');
const logger = require('../../../../Shared/logger');
require('dotenv').config({ path: '../../../../Infrastructure/.env' });

/**
 * Service to handle technician-related operations
 */
class TechnicianService {
  /**
   * Get all jobs for a technician
   * @param {Number} technicianId - The technician user ID
   * @param {Object} filters - Optional filters
   * @returns {Promise<Array>} List of jobs
   */
  async getTechnicianJobs(technicianId, filters = {}) {
    try {
      const whereClause = { technicianId };

      // Filter by status if provided
      if (filters.status) {
        whereClause.status = filters.status;
      }

      // Filter by date range if provided
      if (filters.startDate && filters.endDate) {
        whereClause.scheduledDate = {
          [Op.between]: [new Date(filters.startDate), new Date(filters.endDate)],
        };
      } else if (filters.startDate) {
        whereClause.scheduledDate = {
          [Op.gte]: new Date(filters.startDate),
        };
      } else if (filters.endDate) {
        whereClause.scheduledDate = {
          [Op.lte]: new Date(filters.endDate),
        };
      }

      const jobs = await Job.findAll({
        where: whereClause,
        order: [['scheduledDate', 'ASC']],
      });

      // Fetch service details for the jobs
      await this.enrichJobsWithServiceDetails(jobs);

      return jobs;
    } catch (error) {
      logger.error(`Error fetching jobs for technician ${technicianId}:`, error);
      throw error;
    }
  }

  /**
   * Helper method to enrich jobs with service details
   * @param {Array} jobs - The jobs array to enrich
   */
  async enrichJobsWithServiceDetails(jobs) {
    try {
      // Get unique service IDs
      const serviceIds = [...new Set(jobs.map((job) => job.serviceId))];

      // Fetch service details
      const serviceDetails = {};

      for (const serviceId of serviceIds) {
        try {
          const response = await axios.get(
            `${process.env.CONSUMER_SERVICE_URL}/api/services/${serviceId}`,
          );

          if (response.data && response.data.success) {
            serviceDetails[serviceId] = response.data.service;
          }
        } catch (error) {
          logger.error(`Error fetching service details for ID ${serviceId}:`, error);
        }
      }

      // Add service details to each job
      jobs.forEach((job) => {
        if (serviceDetails[job.serviceId]) {
          job.dataValues.service = serviceDetails[job.serviceId];
        }
      });
    } catch (error) {
      logger.error('Error enriching jobs with service details:', error);
    }
  }

  /**
   * Get job by ID
   * @param {String} jobId - The job ID
   * @param {Number} technicianId - The technician ID (for security check)
   * @returns {Promise<Object>} Job details
   */
  async getJobById(jobId, technicianId) {
    try {
      const job = await Job.findOne({
        where: {
          id: jobId,
          technicianId,
        },
      });

      if (!job) {
        throw new Error('Job not found');
      }

      // Enrich with service details
      await this.enrichJobsWithServiceDetails([job]);

      return job;
    } catch (error) {
      logger.error(`Error fetching job with id ${jobId}:`, error);
      throw error;
    }
  }

  /**
   * Update job status
   * @param {String} jobId - The job ID
   * @param {Number} technicianId - The technician ID
   * @param {String} status - The new status
   * @param {Object} additionalData - Additional data for the status update
   * @returns {Promise<Object>} Updated job
   */
  async updateJobStatus(jobId, technicianId, status, additionalData = {}) {
    try {
      const job = await this.getJobById(jobId, technicianId);

      // Validate status transition
      this.validateStatusTransition(job.status, status);

      // Update job with status and additional data
      const updateData = { status };

      if (status === 'in_progress' && !job.startTime) {
        updateData.startTime = new Date();
      }

      if (status === 'completed' && !job.endTime) {
        updateData.endTime = new Date();
      }

      if (additionalData.notes) {
        updateData.notes = additionalData.notes;
      }

      if (additionalData.completionPhotos) {
        updateData.completionPhotos = additionalData.completionPhotos;
      }

      await job.update(updateData);

      // If job is completed, update the reservation status
      if (status === 'completed') {
        await this.updateReservationStatus(job.reservationId, 'completed');
      } else if (status === 'cancelled') {
        await this.updateReservationStatus(job.reservationId, 'cancelled');
      }

      return job;
    } catch (error) {
      logger.error('Error updating job status:', error);
      throw error;
    }
  }

  /**
   * Validate the status transition logic
   * @param {String} currentStatus - Current job status
   * @param {String} newStatus - New job status
   * @throws {Error} If transition is invalid
   */
  validateStatusTransition(currentStatus, newStatus) {
    const validTransitions = {
      assigned: ['en_route', 'cancelled'],
      en_route: ['in_progress', 'cancelled'],
      in_progress: ['completed', 'cancelled'],
      completed: [],
      cancelled: [],
    };

    if (!validTransitions[currentStatus].includes(newStatus)) {
      throw new Error(`Invalid status transition from ${currentStatus} to ${newStatus}`);
    }
  }

  /**
   * Update reservation status via Consumer Service
   * @param {String} reservationId - The reservation ID
   * @param {String} status - The new status
   * @returns {Promise<void>}
   */
  async updateReservationStatus(reservationId, status) {
    try {
      // Call Consumer Service API to update reservation
      await axios.patch(
        `${process.env.CONSUMER_SERVICE_URL}/api/reservations/${reservationId}/status`,
        { status },
      );
    } catch (error) {
      logger.error('Error updating reservation status:', error);
      throw error;
    }
  }

  /**
   * Get technician's earnings
   * @param {Number} technicianId - The technician ID
   * @param {Object} filters - Optional filters like date range
   * @returns {Promise<Object>} Earnings summary
   */
  async getTechnicianEarnings(technicianId, filters = {}) {
    try {
      const whereClause = {
        technicianId,
        status: 'completed',
        earnings: { [Op.ne]: null },
      };

      // Filter by date range
      if (filters.startDate && filters.endDate) {
        whereClause.endTime = {
          [Op.between]: [new Date(filters.startDate), new Date(filters.endDate)],
        };
      } else if (filters.startDate) {
        whereClause.endTime = {
          [Op.gte]: new Date(filters.startDate),
        };
      } else if (filters.endDate) {
        whereClause.endTime = {
          [Op.lte]: new Date(filters.endDate),
        };
      }

      // Get completed jobs with earnings
      const jobs = await Job.findAll({
        where: whereClause,
        attributes: ['id', 'endTime', 'earnings'],
        order: [['endTime', 'DESC']],
      });

      // Calculate totals
      const totalEarnings = jobs.reduce((sum, job) => {
        return sum + parseFloat(job.earnings);
      }, 0);

      // Group by day, week, month
      const dailyEarnings = this.groupEarningsByPeriod(jobs, 'day');
      const weeklyEarnings = this.groupEarningsByPeriod(jobs, 'week');
      const monthlyEarnings = this.groupEarningsByPeriod(jobs, 'month');

      return {
        totalEarnings,
        completedJobs: jobs.length,
        dailyEarnings,
        weeklyEarnings,
        monthlyEarnings,
        jobs,
      };
    } catch (error) {
      logger.error(`Error fetching earnings for technician ${technicianId}:`, error);
      throw error;
    }
  }

  /**
   * Group earnings by time period
   * @param {Array} jobs - The jobs with earnings
   * @param {String} period - 'day', 'week', or 'month'
   * @returns {Object} Grouped earnings
   */
  groupEarningsByPeriod(jobs, period) {
    const grouped = {};

    jobs.forEach((job) => {
      const date = new Date(job.endTime);
      let key;

      if (period === 'day') {
        key = date.toISOString().split('T')[0]; // YYYY-MM-DD
      } else if (period === 'week') {
        // Get the first day of the week (Sunday)
        const day = date.getUTCDay();
        const diff = date.getUTCDate() - day;
        const firstDay = new Date(date);
        firstDay.setUTCDate(diff);
        key = firstDay.toISOString().split('T')[0];
      } else if (period === 'month') {
        key = `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, '0')}`;
      }

      if (!grouped[key]) {
        grouped[key] = 0;
      }
      grouped[key] += parseFloat(job.earnings);
    });

    return grouped;
  }
}

module.exports = new TechnicianService();
