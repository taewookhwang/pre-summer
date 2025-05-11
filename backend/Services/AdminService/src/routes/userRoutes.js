const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const validators = require('../middleware/validators');
const authMiddleware = require('../middleware/authMiddleware');

/**
 * @route GET /api/users
 * @desc Get all users
 * @access Private (Admin only)
 */
router.get(
  '/',
  authMiddleware.authenticateUser,
  authMiddleware.ensureAdmin,
  userController.getUsers,
);

/**
 * @route GET /api/users/:userId
 * @desc Get user by ID
 * @access Private (Admin only)
 */
router.get(
  '/:userId',
  authMiddleware.authenticateUser,
  authMiddleware.ensureAdmin,
  userController.getUserById,
);

/**
 * @route POST /api/users
 * @desc Create a new user
 * @access Private (Admin only)
 */
router.post(
  '/',
  authMiddleware.authenticateUser,
  authMiddleware.ensureAdmin,
  validators.validateCreateUser,
  userController.createUser,
);

/**
 * @route PUT /api/users/:userId
 * @desc Update a user
 * @access Private (Admin only)
 */
router.put(
  '/:userId',
  authMiddleware.authenticateUser,
  authMiddleware.ensureAdmin,
  validators.validateUpdateUser,
  userController.updateUser,
);

/**
 * @route PATCH /api/users/:userId/password
 * @desc Update user's password
 * @access Private (Admin only)
 */
router.patch(
  '/:userId/password',
  authMiddleware.authenticateUser,
  authMiddleware.ensureAdmin,
  validators.validateUpdatePassword,
  userController.updateUserPassword,
);

/**
 * @route DELETE /api/users/:userId
 * @desc Disable a user account
 * @access Private (Admin only)
 */
router.delete(
  '/:userId',
  authMiddleware.authenticateUser,
  authMiddleware.ensureAdmin,
  userController.disableUser,
);

module.exports = router;
