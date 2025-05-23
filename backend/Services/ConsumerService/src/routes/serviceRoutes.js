const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route GET /api/services/categories
 * @desc Get all service categories
 * @access Public
 */
router.get('/categories', serviceController.getServiceCategories);

/**
 * @route GET /api/services/categories/hierarchical
 * @desc Get all service categories in hierarchical structure
 * @access Public
 */
router.get('/categories/hierarchical', serviceController.getHierarchicalCategories);

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
