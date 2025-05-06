const express = require('express');
const router = express.Router();
const jobController = require('../controllers/jobController');
const validators = require('../middleware/validators');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route GET /api/jobs
 * @desc Get all jobs for a technician
 * @access Private (Technician only)
 */
router.get(
  '/',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('technician'),
  jobController.getTechnicianJobs
);

/**
 * @route GET /api/jobs/:jobId
 * @desc Get job by ID
 * @access Private (Technician only)
 */
router.get(
  '/:jobId',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('technician'),
  jobController.getJobById
);

/**
 * @route PATCH /api/jobs/:jobId/status
 * @desc Update job status
 * @access Private (Technician only)
 */
router.patch(
  '/:jobId/status',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('technician'),
  validators.validateUpdateJobStatus,
  jobController.updateJobStatus
);

module.exports = router;