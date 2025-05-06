const { body, param } = require('express-validator');

const validators = {
  /**
   * Validate reservation creation data
   */
  validateCreateReservation: [
    body('serviceId')
      .notEmpty()
      .withMessage('Service ID is required'),
    
    body('reservationDate')
      .notEmpty()
      .withMessage('Reservation date is required')
      .isISO8601()
      .withMessage('Invalid date format')
      .custom(value => {
        const date = new Date(value);
        const now = new Date();
        if (date < now) {
          throw new Error('Reservation date must be in the future');
        }
        return true;
      }),
    
    body('address')
      .notEmpty()
      .withMessage('Address is required')
      .isLength({ min: 5, max: 500 })
      .withMessage('Address must be between 5 and 500 characters')
  ],
  
  /**
   * Validate reservation status update
   */
  validateUpdateStatus: [
    param('reservationId')
      .notEmpty()
      .withMessage('Reservation ID is required'),
    
    body('status')
      .notEmpty()
      .withMessage('Status is required')
      .isIn(['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'])
      .withMessage('Invalid status value')
  ]
};

module.exports = validators;