const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route GET /api/dashboard/stats
 * @desc Get dashboard statistics
 * @access Private (Admin only)
 */
router.get(
  '/stats',
  authMiddleware.authenticateUser,
  authMiddleware.ensureAdmin,
  dashboardController.getDashboardStats
);

/**
 * @route GET /api/dashboard/services
 * @desc Get service performance metrics
 * @access Private (Admin only)
 */
router.get(
  '/services',
  authMiddleware.authenticateUser,
  authMiddleware.ensureAdmin,
  dashboardController.getServicePerformance
);

module.exports = router;