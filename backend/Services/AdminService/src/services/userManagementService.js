const { sequelize } = require('../../../../Shared/database');
const { QueryTypes } = require('sequelize');
const bcrypt = require('bcrypt');
const logger = require('../../../../Shared/logger');

/**
 * Service to handle user management operations for admins
 */
class UserManagementService {
  /**
   * Get list of users with optional filtering and pagination
   * @param {Object} filters - Optional filters (role, search term, etc.)
   * @param {Object} pagination - Pagination options
   * @returns {Promise<Object>} Users list with pagination info
   */
  async getUsers(filters = {}, pagination = { page: 1, limit: 20 }) {
    try {
      const page = parseInt(pagination.page) || 1;
      const limit = parseInt(pagination.limit) || 20;
      const offset = (page - 1) * limit;
      
      // Build the base query
      let query = `
        SELECT id, email, role, name, phone, address, created_at
        FROM users
        WHERE 1=1
      `;
      
      const queryParams = [];
      
      // Add role filter if provided
      if (filters.role) {
        query += ` AND role = ?`;
        queryParams.push(filters.role);
      }
      
      // Add search filter if provided
      if (filters.search) {
        query += ` AND (
          email ILIKE ? OR
          name ILIKE ? OR
          phone ILIKE ?
        )`;
        const searchTerm = `%${filters.search}%`;
        queryParams.push(searchTerm, searchTerm, searchTerm);
      }
      
      // Get total count for pagination
      const countQuery = `
        SELECT COUNT(*) as total
        FROM (${query}) as filtered_users
      `;
      
      const countResult = await sequelize.query(countQuery, {
        replacements: queryParams,
        type: QueryTypes.SELECT
      });
      
      const total = parseInt(countResult[0]?.total || 0);
      
      // Add pagination to main query
      query += ` ORDER BY created_at DESC LIMIT ? OFFSET ?`;
      queryParams.push(limit, offset);
      
      // Execute the query
      const users = await sequelize.query(query, {
        replacements: queryParams,
        type: QueryTypes.SELECT
      });
      
      return {
        users,
        pagination: {
          total,
          page,
          limit,
          pages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      logger.error('Error fetching users:', error);
      throw error;
    }
  }
  
  /**
   * Get user by ID
   * @param {Number} userId - The user ID
   * @returns {Promise<Object>} User details
   */
  async getUserById(userId) {
    try {
      const query = `
        SELECT id, email, role, name, phone, address, created_at
        FROM users
        WHERE id = ?
      `;
      
      const results = await sequelize.query(query, {
        replacements: [userId],
        type: QueryTypes.SELECT
      });
      
      if (results.length === 0) {
        throw new Error('User not found');
      }
      
      return results[0];
    } catch (error) {
      logger.error(`Error fetching user with id ${userId}:`, error);
      throw error;
    }
  }
  
  /**
   * Create a new user
   * @param {Object} userData - User data
   * @returns {Promise<Object>} Created user
   */
  async createUser(userData) {
    try {
      // Hash the password
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(userData.password, salt);
      
      // Validate role
      if (!['consumer', 'technician', 'admin'].includes(userData.role)) {
        throw new Error('Invalid role. Role must be consumer, technician, or admin');
      }
      
      // Check if email already exists
      const existingUser = await sequelize.query(
        'SELECT id FROM users WHERE email = ?',
        {
          replacements: [userData.email],
          type: QueryTypes.SELECT
        }
      );
      
      if (existingUser.length > 0) {
        throw new Error('Email already in use');
      }
      
      // Insert the new user
      const query = `
        INSERT INTO users (email, password_hash, role, name, phone, address, created_at)
        VALUES (?, ?, ?, ?, ?, ?, NOW())
        RETURNING id, email, role, name, phone, address, created_at
      `;
      
      const results = await sequelize.query(query, {
        replacements: [
          userData.email,
          passwordHash,
          userData.role,
          userData.name || null,
          userData.phone || null,
          userData.address || null
        ],
        type: QueryTypes.SELECT
      });
      
      return results[0];
    } catch (error) {
      logger.error('Error creating user:', error);
      throw error;
    }
  }
  
  /**
   * Update a user
   * @param {Number} userId - The user ID
   * @param {Object} userData - Updated user data
   * @returns {Promise<Object>} Updated user
   */
  async updateUser(userId, userData) {
    try {
      // Get the existing user
      const user = await this.getUserById(userId);
      
      // Build the update query
      let query = 'UPDATE users SET ';
      const queryParams = [];
      const updateFields = [];
      
      if (userData.name !== undefined) {
        updateFields.push('name = ?');
        queryParams.push(userData.name);
      }
      
      if (userData.phone !== undefined) {
        updateFields.push('phone = ?');
        queryParams.push(userData.phone);
      }
      
      if (userData.address !== undefined) {
        updateFields.push('address = ?');
        queryParams.push(userData.address);
      }
      
      if (userData.role !== undefined) {
        if (!['consumer', 'technician', 'admin'].includes(userData.role)) {
          throw new Error('Invalid role. Role must be consumer, technician, or admin');
        }
        updateFields.push('role = ?');
        queryParams.push(userData.role);
      }
      
      // Ensure there are fields to update
      if (updateFields.length === 0) {
        return user;
      }
      
      query += updateFields.join(', ');
      query += ' WHERE id = ? RETURNING id, email, role, name, phone, address, created_at';
      queryParams.push(userId);
      
      // Execute the update
      const results = await sequelize.query(query, {
        replacements: queryParams,
        type: QueryTypes.SELECT
      });
      
      return results[0];
    } catch (error) {
      logger.error(`Error updating user with id ${userId}:`, error);
      throw error;
    }
  }
  
  /**
   * Update user's password
   * @param {Number} userId - The user ID
   * @param {String} newPassword - The new password
   * @returns {Promise<Boolean>} Success indicator
   */
  async updateUserPassword(userId, newPassword) {
    try {
      // Hash the new password
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(newPassword, salt);
      
      // Update the password
      const query = `
        UPDATE users
        SET password_hash = ?
        WHERE id = ?
      `;
      
      await sequelize.query(query, {
        replacements: [passwordHash, userId],
        type: QueryTypes.UPDATE
      });
      
      return true;
    } catch (error) {
      logger.error(`Error updating password for user with id ${userId}:`, error);
      throw error;
    }
  }
  
  /**
   * Disable a user account (soft delete)
   * @param {Number} userId - The user ID
   * @returns {Promise<Boolean>} Success indicator
   */
  async disableUser(userId) {
    try {
      // This is a soft delete implementation
      // You could also implement it differently based on your requirements
      const query = `
        UPDATE users
        SET is_active = false
        WHERE id = ?
      `;
      
      await sequelize.query(query, {
        replacements: [userId],
        type: QueryTypes.UPDATE
      });
      
      return true;
    } catch (error) {
      logger.error(`Error disabling user with id ${userId}:`, error);
      throw error;
    }
  }
}

module.exports = new UserManagementService();