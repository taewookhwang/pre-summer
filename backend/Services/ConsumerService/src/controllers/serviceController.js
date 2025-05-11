const consumerService = require('../services/consumerService');
const { validationResult } = require('express-validator');
const logger = require('../../../../Shared/logger');

/**
 * Controller for handling service-related requests
 */
const serviceController = {
  /**
   * Get all service categories
   */
  getServiceCategories: async (req, res) => {
    try {
      const categories = await consumerService.getServiceCategories();

      // 응답 형식 변환 (camelCase -> snake_case)
      const formattedCategories = categories.map((category) => ({
        id: category.id,
        name: category.name,
        icon_url: category.iconUrl,
        subcategories:
          category.subcategories?.map((sub) => ({
            id: sub.id,
            name: sub.name,
            parent_id: sub.parentId,
          })) || [],
      }));

      // iOS 앱 호환을 위해 categories를 최상위 레벨에 배치
      return res.status(200).json({
        success: true,
        categories: formattedCategories,
      });
    } catch (error) {
      logger.error('Error getting service categories:', error);

      return res.status(500).json({
        success: false,
        code: 'server_error',
        message: 'Failed to fetch service categories',
        suggestion: 'Please try again later',
      });
    }
  },

  /**
   * Get all service categories in hierarchical structure
   * (Specialized endpoint for iOS app)
   */
  getHierarchicalCategories: async (req, res) => {
    try {
      const categories = await consumerService.getServiceCategories();

      // 응답 형식 변환 (camelCase -> snake_case)
      // iOS 앱을 위한 계층적 데이터 구조로 변환
      const formattedCategories = categories.map((category) => ({
        id: category.id,
        name: category.name,
        icon_url: category.iconUrl,
        subcategories:
          category.subcategories?.map((sub) => ({
            id: sub.id,
            name: sub.name,
            parent_id: sub.parentId,
          })) || [],
      }));

      // iOS 앱 호환을 위해 categories와 메타데이터를 최상위 레벨에 배치
      return res.status(200).json({
        success: true,
        categories: formattedCategories,
        endpoint_type: 'hierarchical',
      });
    } catch (error) {
      logger.error('Error getting hierarchical service categories:', error);

      return res.status(500).json({
        success: false,
        code: 'server_error',
        message: 'Failed to fetch hierarchical service categories',
        suggestion: 'Please try again later',
      });
    }
  },

  /**
   * Get subcategories for a category
   */
  getSubcategoriesByCategory: async (req, res) => {
    try {
      const { categoryId } = req.params;

      const subcategories = await consumerService.getSubcategoriesByCategory(categoryId);

      // 응답 형식 변환 (camelCase -> snake_case)
      const formattedSubcategories = subcategories.map((sub) => ({
        id: sub.id,
        name: sub.name,
        parent_id: sub.parentId,
      }));

      return res.status(200).json({
        success: true,
        data: {
          subcategories: formattedSubcategories,
        },
      });
    } catch (error) {
      logger.error(`Error getting subcategories for category ${req.params.categoryId}:`, error);

      return res.status(500).json({
        success: false,
        code: 'server_error',
        message: 'Failed to fetch subcategories',
        suggestion: 'Please try again later',
      });
    }
  },

  /**
   * Get services by category or subcategory
   */
  getServicesByCategory: async (req, res) => {
    try {
      const { categoryId } = req.params;
      const { subcategoryId } = req.query;

      // Extract pagination parameters
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;

      const result = await consumerService.getServicesByCategory(
        categoryId,
        subcategoryId,
        page,
        limit,
      );

      // 응답 형식 변환 (camelCase -> snake_case)
      const formattedServices = result.services.map((service) => ({
        id: service.id,
        name: service.name,
        short_description: service.shortDescription,
        base_price: service.basePrice,
        unit: service.unit,
        duration: service.duration,
        category_id: service.categoryId,
        subcategory_id: service.subcategoryId,
        thumbnail: service.thumbnail,
      }));

      return res.status(200).json({
        success: true,
        data: formattedServices,
        pagination: {
          page: result.pagination.page,
          limit: result.pagination.limit,
          total_items: result.pagination.total,
          total_pages: result.pagination.total_pages,
        },
      });
    } catch (error) {
      logger.error(`Error getting services for category ${req.params.categoryId}:`, error);

      return res.status(500).json({
        success: false,
        code: 'server_error',
        message: 'Failed to fetch services',
        suggestion: 'Please try again later',
      });
    }
  },

  /**
   * Get all services with pagination
   */
  getAllServices: async (req, res) => {
    try {
      // Extract filters
      const filters = {
        category: req.query.category,
        subcategory: req.query.subcategory,
        minPrice: req.query.min_price ? parseFloat(req.query.min_price) : null,
        maxPrice: req.query.max_price ? parseFloat(req.query.max_price) : null,
      };

      // Extract pagination parameters
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;

      // Get paginated services
      const result = await consumerService.getServices(filters, page, limit);

      // 응답 형식 변환 (camelCase -> snake_case)
      const formattedServices = result.services.map((service) => ({
        id: service.id,
        name: service.name,
        short_description: service.shortDescription,
        description: service.description,
        base_price: service.basePrice,
        unit: service.unit,
        duration: service.duration,
        category_id: service.categoryId,
        subcategory_id: service.subcategoryId,
        category: service.category
          ? {
              id: service.category.id,
              name: service.category.name,
            }
          : null,
        subcategory: service.subcategory
          ? {
              id: service.subcategory.id,
              name: service.subcategory.name,
              parent_id: service.subcategory.parentId,
            }
          : null,
        thumbnail: service.thumbnail,
        is_active: service.isActive,
      }));

      return res.status(200).json({
        success: true,
        data: formattedServices,
        pagination: {
          page: result.pagination.page,
          limit: result.pagination.limit,
          total_items: result.pagination.total,
          total_pages: result.pagination.total_pages,
        },
      });
    } catch (error) {
      logger.error('Error getting all services:', error);

      return res.status(500).json({
        success: false,
        code: 'server_error',
        message: 'Failed to fetch services',
        suggestion: 'Please try again later',
      });
    }
  },

  /**
   * Get service by ID with all details
   */
  getServiceById: async (req, res) => {
    try {
      const { serviceId } = req.params;
      const service = await consumerService.getServiceById(serviceId);

      if (!service) {
        return res.status(404).json({
          success: false,
          code: 'not_found',
          message: 'Service not found',
          suggestion: 'Check the service ID and try again',
        });
      }

      // 응답 형식 변환 (camelCase -> snake_case)
      const formattedService = {
        id: service.id,
        name: service.name,
        short_description: service.shortDescription,
        description: service.description,
        base_price: service.basePrice,
        unit: service.unit,
        duration: service.duration,
        category_id: service.categoryId,
        subcategory_id: service.subcategoryId,
        category: service.category
          ? {
              id: service.category.id,
              name: service.category.name,
            }
          : null,
        subcategory: service.subcategory
          ? {
              id: service.subcategory.id,
              name: service.subcategory.name,
              parent_id: service.subcategory.parentId,
            }
          : null,
        thumbnail: service.thumbnail,
        images: [], // 추후 이미지 정보 추가
        options:
          service.options?.map((option) => ({
            id: option.id,
            name: option.name,
            description: option.description,
            price: option.price,
          })) || [],
        required_fields:
          service.customFields?.filter((field) => field.isRequired).map((field) => field.name) ||
          [],
        custom_fields:
          service.customFields?.map((field) => ({
            id: field.id,
            name: field.name,
            type: field.type,
            required: field.isRequired,
            options: field.options,
            default_value: field.defaultValue,
          })) || [],
        ratings: service.ratings,
        reviews: service.reviews,
        is_active: service.isActive,
      };

      return res.status(200).json({
        success: true,
        data: formattedService,
      });
    } catch (error) {
      logger.error(`Error getting service ${req.params.serviceId}:`, error);

      // 서비스를 찾지 못한 경우 404 응답
      if (error.message === 'Service not found') {
        return res.status(404).json({
          success: false,
          code: 'not_found',
          message: 'Service not found',
          suggestion: 'Check the service ID and try again',
        });
      }

      return res.status(500).json({
        success: false,
        code: 'server_error',
        message: 'Failed to fetch service details',
        suggestion: 'Please try again later',
      });
    }
  },
};

module.exports = serviceController;
