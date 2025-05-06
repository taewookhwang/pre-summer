const userManagementService = require('../services/userManagementService');
const { validationResult } = require('express-validator');
const logger = require('../../../../Shared/logger');

/**
 * Controller for handling user management requests
 */
const userController = {
  /**
   * Get all users
   */
  getUsers: async (req, res) => {
    try {
      const filters = {
        role: req.query.role,
        search: req.query.search
      };
      
      const pagination = {
        page: parseInt(req.query.page) || 1,
        limit: parseInt(req.query.limit) || 20
      };
      
      const result = await userManagementService.getUsers(filters, pagination);
      
      // 유저 필드 snake_case로 변환
      const formattedUsers = result.users.map(user => ({
        id: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
        phone: user.phone,
        address: user.address,
        created_at: user.created_at // DB에서 이미 snake_case로 오는 필드
      }));
      
      // 페이지네이션 정보도 snake_case로 변환
      const formattedPagination = {
        total: result.pagination.total,
        page: result.pagination.page,
        limit: result.pagination.limit,
        pages: result.pagination.pages
      };
      
      return res.status(200).json({
        success: true,
        users: formattedUsers,
        pagination: formattedPagination
      });
    } catch (error) {
      logger.error('Error in getUsers controller:', error);
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch users',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Get user by ID
   */
  getUserById: async (req, res) => {
    try {
      const { userId } = req.params;
      
      const user = await userManagementService.getUserById(userId);
      
      // snake_case로 변환
      const formattedUser = {
        id: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
        phone: user.phone,
        address: user.address,
        created_at: user.created_at // DB에서 이미 snake_case로 오는 필드
      };
      
      return res.status(200).json({
        success: true,
        user: formattedUser
      });
    } catch (error) {
      return res.status(error.message === 'User not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to fetch user',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Create a new user
   */
  createUser: async (req, res) => {
    try {
      // Validate request data
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'Validation failed',
            details: errors.array().map(err => ({
              field: err.param,
              message: err.msg
            }))
          }
        });
      }
      
      const userData = {
        email: req.body.email,
        password: req.body.password,
        role: req.body.role,
        name: req.body.name,
        phone: req.body.phone,
        address: req.body.address
      };
      
      const user = await userManagementService.createUser(userData);
      
      // snake_case로 변환
      const formattedUser = {
        id: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
        phone: user.phone,
        address: user.address,
        created_at: user.created_at
      };
      
      return res.status(201).json({
        success: true,
        user: formattedUser
      });
    } catch (error) {
      const statusCode = error.message.includes('Email already in use') ? 409 : 500;
      
      return res.status(statusCode).json({
        success: false,
        error: {
          message: error.message || 'Failed to create user',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Update a user
   */
  updateUser: async (req, res) => {
    try {
      // Validate request data
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'Validation failed',
            details: errors.array().map(err => ({
              field: err.param,
              message: err.msg
            }))
          }
        });
      }
      
      const { userId } = req.params;
      
      const userData = {
        name: req.body.name,
        phone: req.body.phone,
        address: req.body.address,
        role: req.body.role
      };
      
      const user = await userManagementService.updateUser(userId, userData);
      
      // snake_case로 변환
      const formattedUser = {
        id: user.id,
        email: user.email,
        role: user.role,
        name: user.name,
        phone: user.phone,
        address: user.address,
        created_at: user.created_at
      };
      
      return res.status(200).json({
        success: true,
        user: formattedUser
      });
    } catch (error) {
      return res.status(error.message === 'User not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to update user',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Update user's password
   */
  updateUserPassword: async (req, res) => {
    try {
      // Validate request data
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'Validation failed',
            details: errors.array().map(err => ({
              field: err.param,
              message: err.msg
            }))
          }
        });
      }
      
      const { userId } = req.params;
      const { password } = req.body;
      
      await userManagementService.updateUserPassword(userId, password);
      
      return res.status(200).json({
        success: true,
        message: 'Password updated successfully'
      });
    } catch (error) {
      return res.status(error.message === 'User not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to update password',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Disable a user account
   */
  disableUser: async (req, res) => {
    try {
      const { userId } = req.params;
      
      await userManagementService.disableUser(userId);
      
      return res.status(200).json({
        success: true,
        message: 'User account disabled successfully'
      });
    } catch (error) {
      return res.status(error.message === 'User not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to disable user account',
          details: error.message
        }
      });
    }
  }
};

module.exports = userController;