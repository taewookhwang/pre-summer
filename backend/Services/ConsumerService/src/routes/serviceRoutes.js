const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route GET /api/services
 * @desc Get all services
 * @access Public
 */
router.get('/', serviceController.getAllServices);

/**
 * @route GET /api/services/:serviceId
 * @desc Get service by ID
 * @access Public
 */
router.get('/:serviceId', serviceController.getServiceById);

module.exports = router;