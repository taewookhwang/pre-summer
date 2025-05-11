const express = require('express');
const router = express.Router();
const earningsController = require('../controllers/earningsController');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route GET /api/earnings
 * @desc Get technician's earnings
 * @access Private (Technician only)
 */
router.get(
  '/',
  authMiddleware.authenticateUser,
  authMiddleware.restrictTo('technician'),
  earningsController.getTechnicianEarnings,
);

module.exports = router;
