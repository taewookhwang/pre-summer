const { body, param } = require('express-validator');

const validators = {
  /**
   * 매칭 생성 요청 검증
   */
  validateCreateMatching: [
    body('reservation_id')
      .notEmpty()
      .withMessage('Reservation ID is required')
      .isUUID()
      .withMessage('Invalid Reservation ID format'),

    body('max_distance')
      .optional()
      .isFloat({ min: 0.5, max: 50 })
      .withMessage('Max distance must be between 0.5 and 50 km'),

    body('priority_factors')
      .optional()
      .isArray()
      .withMessage('Priority factors must be an array')
      .custom((factors) => {
        if (!factors) return true;

        const allowedFactors = ['distance', 'rating', 'experience'];
        return factors.every((factor) => allowedFactors.includes(factor));
      })
      .withMessage('Invalid priority factors. Allowed values: distance, rating, experience'),
  ],

  /**
   * 매칭 응답 요청 검증
   */
  validateRespondToMatching: [
    param('matchingId')
      .notEmpty()
      .withMessage('Matching ID is required')
      .isUUID()
      .withMessage('Invalid Matching ID format'),

    body('accept')
      .notEmpty()
      .withMessage('Accept is required')
      .isBoolean()
      .withMessage('Accept must be a boolean'),

    body('decline_reason')
      .if(body('accept').equals('false'))
      .notEmpty()
      .withMessage('Decline reason is required when declining')
      .isLength({ max: 200 })
      .withMessage('Decline reason must be less than 200 characters'),

    body('estimated_arrival')
      .if(body('accept').equals('true'))
      .optional()
      .isISO8601()
      .withMessage('Estimated arrival must be a valid date')
      .custom((value) => {
        const date = new Date(value);
        const now = new Date();

        // 현재 시간 이후인지 확인
        if (date <= now) {
          throw new Error('Estimated arrival must be in the future');
        }

        // 24시간 이내인지 확인
        const maxDate = new Date();
        maxDate.setHours(maxDate.getHours() + 24);

        if (date > maxDate) {
          throw new Error('Estimated arrival must be within 24 hours');
        }

        return true;
      }),
  ],
};

module.exports = validators;
