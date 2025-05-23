const { body, validationResult } = require('express-validator');

/**
 * ��  �1 ��  ���
 */
const validators = {
  /**
   * tT|  �1 ��
   */
  email: body('email')
    .notEmpty()
    .withMessage('tT|@ D m����.')
    .isEmail()
    .withMessage(' �\ tT| ��| �%t �8�.')
    .normalizeEmail(),

  /**
   * D �8  �1 ��
   */
  password: body('password')
    .notEmpty()
    .withMessage('D �8� D m����.')
    .isLength({ min: 8 })
    .withMessage('D �8� \� 8� t�t�| i��.')
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('D �8�  8�, �8�, +�, �8�|  X� t� �ht| i��.'),

  /**
   * ��� t�  �1 ��
   */
  name: body('name')
    .notEmpty()
    .withMessage('t�@ D m����.')
    .isLength({ min: 2, max: 50 })
    .withMessage('t�@ 2� t� 50� tX�| i��.')
    .matches(/^[ -�a-zA-Z\s]+$/)
    .withMessage('t�@ \ , 8, �1� �h`  ����.'),

  /**
   * T�8  �1 ��
   */
  phone: body('phone')
    .notEmpty()
    .withMessage('T�8� D m����.')
    .matches(/^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$/)
    .withMessage(' �\ T�8 �D �%t �8� (: 010-1234-5678)'),

  /**
   * ��  �1 ��
   */
  address: body('address')
    .notEmpty()
    .withMessage('��� D m����.')
    .isLength({ min: 5, max: 200 })
    .withMessage('��� 5� t� 200� tX�| i��.'),

  /**
   * ��  �1 ��
   */
  date: (field) => {
    return body(field)
      .notEmpty()
      .withMessage('�ܔ D m����.')
      .isISO8601()
      .withMessage(' �\ �� �D �%t �8� (YYYY-MM-DD)')
      .toDate();
  },

  /**
   *  �  �1 ��
   */
  price: (field) => {
    return body(field)
      .notEmpty()
      .withMessage(' �@ D m����.')
      .isNumeric()
      .withMessage(' �@ +��| i��.')
      .custom((value) => {
        const price = Number(value);
        if (price <= 0) {
          throw new Error(' �@ 0�� �| i��.');
        }
        return true;
      })
      .toFloat();
  },
};

/**
 *  �1 �� �� �� ���
 */
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      errors: errors.array().map((err) => ({
        field: err.param,
        message: err.msg,
      })),
    });
  }
  next();
};

module.exports = {
  validators,
  handleValidationErrors,
};
