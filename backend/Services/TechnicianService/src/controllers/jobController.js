const technicianService = require('../services/technicianService');
const { validationResult } = require('express-validator');
const logger = require('../../../../Shared/logger');

/**
 * Controller for handling job-related requests
 */
const jobController = {
  /**
   * Get all jobs for a technician
   */
  getTechnicianJobs: async (req, res) => {
    try {
      const technicianId = req.user.id; // Assuming auth middleware sets the user
      
      // Parse filter parameters
      const filters = {};
      
      if (req.query.status) {
        filters.status = req.query.status;
      }
      
      if (req.query.startDate) {
        filters.startDate = req.query.startDate;
      }
      
      if (req.query.endDate) {
        filters.endDate = req.query.endDate;
      }
      
      const jobs = await technicianService.getTechnicianJobs(technicianId, filters);
      
      // 응답 형식 변경: snake_case 사용
      const formattedJobs = jobs.map(job => {
        const formatted = {
          id: job.id,
          reservation_id: job.reservationId,
          technician_id: job.technicianId,
          consumer_id: job.consumerId,
          service_id: job.serviceId,
          scheduled_date: job.scheduledDate,
          start_time: job.startTime,
          end_time: job.endTime,
          status: job.status,
          address: job.address,
          notes: job.notes,
          completion_photos: job.completionPhotos,
          earnings: job.earnings,
          rating: job.rating,
          created_at: job.createdAt,
          updated_at: job.updatedAt
        };
        
        // 서비스 정보가 포함된 경우 변환
        if (job.dataValues && job.dataValues.service) {
          formatted.service = {
            id: job.dataValues.service.id,
            name: job.dataValues.service.name,
            description: job.dataValues.service.description,
            price: job.dataValues.service.price,
            duration: job.dataValues.service.duration,
            category: job.dataValues.service.category,
            is_active: job.dataValues.service.isActive
          };
        }
        
        return formatted;
      });
      
      return res.status(200).json({
        success: true,
        jobs: formattedJobs
      });
    } catch (error) {
      logger.error('Error in getTechnicianJobs controller:', error);
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch jobs',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Get job by ID
   */
  getJobById: async (req, res) => {
    try {
      const { jobId } = req.params;
      const technicianId = req.user.id; // Assuming auth middleware sets the user
      
      const job = await technicianService.getJobById(jobId, technicianId);
      
      // 응답 형식 변경: snake_case 사용
      const formattedJob = {
        id: job.id,
        reservation_id: job.reservationId,
        technician_id: job.technicianId,
        consumer_id: job.consumerId,
        service_id: job.serviceId,
        scheduled_date: job.scheduledDate,
        start_time: job.startTime,
        end_time: job.endTime,
        status: job.status,
        address: job.address,
        notes: job.notes,
        completion_photos: job.completionPhotos,
        earnings: job.earnings,
        rating: job.rating,
        created_at: job.createdAt,
        updated_at: job.updatedAt
      };
      
      // 서비스 정보가 포함된 경우 변환
      if (job.dataValues && job.dataValues.service) {
        formattedJob.service = {
          id: job.dataValues.service.id,
          name: job.dataValues.service.name,
          description: job.dataValues.service.description,
          price: job.dataValues.service.price,
          duration: job.dataValues.service.duration,
          category: job.dataValues.service.category,
          is_active: job.dataValues.service.isActive
        };
      }
      
      return res.status(200).json({
        success: true,
        job: formattedJob
      });
    } catch (error) {
      return res.status(error.message === 'Job not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to fetch job',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Update job status
   */
  updateJobStatus: async (req, res) => {
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
      
      const { jobId } = req.params;
      const technicianId = req.user.id; // Assuming auth middleware sets the user
      const { status, notes, completionPhotos } = req.body;
      
      const additionalData = {};
      if (notes) additionalData.notes = notes;
      if (completionPhotos) additionalData.completionPhotos = completionPhotos;
      
      const updatedJob = await technicianService.updateJobStatus(
        jobId,
        technicianId,
        status,
        additionalData
      );
      
      // 응답 형식 변경: snake_case 사용
      const formattedJob = {
        id: updatedJob.id,
        reservation_id: updatedJob.reservationId,
        technician_id: updatedJob.technicianId,
        consumer_id: updatedJob.consumerId,
        service_id: updatedJob.serviceId,
        scheduled_date: updatedJob.scheduledDate,
        start_time: updatedJob.startTime,
        end_time: updatedJob.endTime,
        status: updatedJob.status,
        address: updatedJob.address,
        notes: updatedJob.notes,
        completion_photos: updatedJob.completionPhotos,
        earnings: updatedJob.earnings,
        rating: updatedJob.rating,
        created_at: updatedJob.createdAt,
        updated_at: updatedJob.updatedAt
      };
      
      // 서비스 정보가 포함된 경우 변환
      if (updatedJob.dataValues && updatedJob.dataValues.service) {
        formattedJob.service = {
          id: updatedJob.dataValues.service.id,
          name: updatedJob.dataValues.service.name,
          description: updatedJob.dataValues.service.description,
          price: updatedJob.dataValues.service.price,
          duration: updatedJob.dataValues.service.duration,
          category: updatedJob.dataValues.service.category,
          is_active: updatedJob.dataValues.service.isActive
        };
      }
      
      return res.status(200).json({
        success: true,
        job: formattedJob
      });
    } catch (error) {
      const statusCode = 
        error.message === 'Job not found' ? 404 :
        error.message.includes('Invalid status transition') ? 400 : 
        500;
      
      return res.status(statusCode).json({
        success: false,
        error: {
          message: error.message || 'Failed to update job status',
          details: error.message
        }
      });
    }
  }
};

module.exports = jobController;