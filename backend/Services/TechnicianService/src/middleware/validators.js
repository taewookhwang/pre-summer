const { body, param } = require('express-validator');

const validators = {
  /**
   * Validate job status update
   */
  validateUpdateJobStatus: [
    param('jobId')
      .notEmpty()
      .withMessage('Job ID is required'),
    
    body('status')
      .notEmpty()
      .withMessage('Status is required')
      .isIn(['assigned', 'en_route', 'in_progress', 'completed', 'cancelled'])
      .withMessage('Invalid status value'),
    
    body('notes')
      .optional()
      .isString()
      .withMessage('Notes must be a string')
      .isLength({ max: 1000 })
      .withMessage('Notes cannot exceed 1000 characters'),
    
    body('completionPhotos')
      .optional()
      .isArray()
      .withMessage('completionPhotos must be an array of photo URLs')
  ]
};

module.exports = validators;