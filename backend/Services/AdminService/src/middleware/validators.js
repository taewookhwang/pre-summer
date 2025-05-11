const { body, param } = require('express-validator');

const validators = {
  /**
   * Validate user creation data
   */
  validateCreateUser: [
    body('email')
      .notEmpty()
      .withMessage('Email is required')
      .isEmail()
      .withMessage('Invalid email format'),

    body('password')
      .notEmpty()
      .withMessage('Password is required')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters'),

    body('role')
      .notEmpty()
      .withMessage('Role is required')
      .isIn(['consumer', 'technician', 'admin'])
      .withMessage('Role must be consumer, technician, or admin'),

    body('name')
      .optional()
      .isLength({ min: 2, max: 100 })
      .withMessage('Name must be between 2 and 100 characters'),

    body('phone')
      .optional()
      .isLength({ min: 10, max: 20 })
      .withMessage('Phone must be between 10 and 20 characters'),

    body('address')
      .optional()
      .isLength({ max: 500 })
      .withMessage('Address cannot exceed 500 characters'),
  ],

  /**
   * Validate user update data
   */
  validateUpdateUser: [
    param('userId')
      .notEmpty()
      .withMessage('User ID is required')
      .isInt()
      .withMessage('User ID must be an integer'),

    body('name')
      .optional()
      .isLength({ min: 2, max: 100 })
      .withMessage('Name must be between 2 and 100 characters'),

    body('phone')
      .optional()
      .isLength({ min: 10, max: 20 })
      .withMessage('Phone must be between 10 and 20 characters'),

    body('address')
      .optional()
      .isLength({ max: 500 })
      .withMessage('Address cannot exceed 500 characters'),

    body('role')
      .optional()
      .isIn(['consumer', 'technician', 'admin'])
      .withMessage('Role must be consumer, technician, or admin'),
  ],

  /**
   * Validate password update
   */
  validateUpdatePassword: [
    param('userId')
      .notEmpty()
      .withMessage('User ID is required')
      .isInt()
      .withMessage('User ID must be an integer'),

    body('password')
      .notEmpty()
      .withMessage('Password is required')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters'),
  ],
};

module.exports = validators;
