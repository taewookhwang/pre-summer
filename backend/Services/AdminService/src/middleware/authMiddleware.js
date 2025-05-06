const jwt = require('jsonwebtoken');
require('dotenv').config({ path: '../../../../Infrastructure/.env' });
const logger = require('../../../../Shared/logger');

/**
 * Authenticate user using JWT token
 */
exports.authenticateUser = (req, res, next) => {
  try {
    let token;
    
    // Extract token from request headers
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }
    
    // Check if token exists
    if (!token) {
      return res.status(401).json({
        success: false,
        error: {
          message: 'Authentication required. Please login.',
          details: 'No authentication token provided'
        }
      });
    }
    
    try {
      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Set user info in request object
      req.user = {
        id: decoded.id,
        email: decoded.email,
        role: decoded.role,
        name: decoded.name
      };
      
      next();
    } catch (error) {
      logger.error('Token verification failed:', error);
      return res.status(401).json({
        success: false,
        error: {
          message: 'Invalid or expired token. Please login again.',
          details: error.message
        }
      });
    }
  } catch (error) {
    logger.error('Auth middleware error:', error);
    return res.status(500).json({
      success: false,
      error: {
        message: 'Internal server error',
        details: error.message
      }
    });
  }
};

/**
 * Ensure user is an admin
 */
exports.ensureAdmin = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      error: {
        message: 'User not authenticated',
        details: 'Authentication required'
      }
    });
  }
  
  if (req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      error: {
        message: 'Access denied. Admin privileges required.',
        details: `User role '${req.user.role}' does not have admin privileges`
      }
    });
  }
  
  next();
};