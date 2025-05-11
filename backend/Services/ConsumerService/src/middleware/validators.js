const { body, param } = require('express-validator');

const validators = {
  /**
   * Validate reservation creation data
   */
  validateCreateReservation: [
    body('service_id').notEmpty().withMessage('Service ID is required'),

    body('scheduled_time')
      .notEmpty()
      .withMessage('Scheduled time is required')
      .isISO8601()
      .withMessage('Invalid date format')
      .custom((value) => {
        const date = new Date(value);
        const now = new Date();
        if (date < now) {
          throw new Error('Scheduled time must be in the future');
        }
        return true;
      }),

    body('address')
      .notEmpty()
      .withMessage('Address is required')
      .isObject()
      .withMessage('Address must be an object'),

    body('address.street')
      .notEmpty()
      .withMessage('Street address is required')
      .isLength({ min: 5, max: 200 })
      .withMessage('Street address must be between 5 and 200 characters'),

    body('address.detail')
      .optional()
      .isLength({ max: 200 })
      .withMessage('Address detail must be maximum 200 characters'),

    body('address.postal_code')
      .optional()
      .isLength({ max: 20 })
      .withMessage('Postal code must be maximum 20 characters'),

    body('address.coordinates').optional().isObject().withMessage('Coordinates must be an object'),

    body('address.coordinates.latitude')
      .optional()
      .isFloat({ min: -90, max: 90 })
      .withMessage('Latitude must be between -90 and 90'),

    body('address.coordinates.longitude')
      .optional()
      .isFloat({ min: -180, max: 180 })
      .withMessage('Longitude must be between -180 and 180'),

    body('service_options').optional().isArray().withMessage('Service options must be an array'),

    body('service_options.*.option_id')
      .optional()
      .notEmpty()
      .withMessage('Option ID is required for each service option'),

    body('service_options.*.quantity')
      .optional()
      .isInt({ min: 1 })
      .withMessage('Quantity must be a positive integer'),

    body('custom_fields').optional().isObject().withMessage('Custom fields must be an object'),

    body('special_instructions')
      .optional()
      .isLength({ max: 1000 })
      .withMessage('Special instructions must be maximum 1000 characters'),
  ],

  /**
   * Validate reservation status update
   */
  validateUpdateStatus: [
    param('reservationId').notEmpty().withMessage('Reservation ID is required'),

    body('status')
      .notEmpty()
      .withMessage('Status is required')
      .isIn([
        'pending',
        'searching_technician',
        'technician_assigned',
        'in_progress',
        'completed',
        'cancelled',
      ])
      .withMessage('Invalid status value'),

    body('reason')
      .optional()
      .isLength({ max: 500 })
      .withMessage('Reason must be maximum 500 characters'),
  ],
};

module.exports = validators;
