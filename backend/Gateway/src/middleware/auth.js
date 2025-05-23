const jwt = require('jsonwebtoken');
const axios = require('axios');
require('dotenv').config({ path: '../../../Infrastructure/.env' });
const logger = require('../../../Shared/logger');

/**
 * �p �� ���
 * �� �T� x� �pD ��X� ��i��.
 */
exports.verifyToken = async (req, res, next) => {
  try {
    let token;

    // �� �T� �p ��
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    // �pt Ɣ ��
    if (!token) {
      logger.info('Token missing in request');
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
    }

    try {
      // �p ��
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // ��� � AuthService� ��
      try {
        const response = await axios.get(`${process.env.AUTH_SERVICE_URL}/api/auth/verify`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        if (response.data && response.data.success) {
          // req �� ��� �  �
          req.user = response.data.data;
          next();
        } else {
          throw new Error('User verification failed');
        }
      } catch (error) {
        logger.error('Error verifying token with Auth Service:', error);
        return res.status(401).json({
          success: false,
          message: 'Authentication failed',
        });
      }
    } catch (error) {
      logger.error('Token verification failed:', error);
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired token',
      });
    }
  } catch (error) {
    logger.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      message: 'Internal server error',
    });
  }
};

/**
 * � �`X ���� �  �X�] X� ���
 * @param {...string} roles - ȩ �` �]
 */
exports.restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !req.user.role) {
      logger.info('User role missing in request');
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
    }

    if (!roles.includes(req.user.role)) {
      logger.info(`Access denied for role ${req.user.role}`);
      return res.status(403).json({
        success: false,
        message: 'Access denied',
      });
    }

    next();
  };
};
