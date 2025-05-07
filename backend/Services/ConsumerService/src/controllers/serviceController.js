const consumerService = require('../services/consumerService');
const { validationResult } = require('express-validator');

/**
 * Controller for handling service-related requests
 */
const serviceController = {
  /**
   * Get all services
   */
  getAllServices: async (req, res) => {
    try {
      const filters = {
        category: req.query.category,
        minPrice: req.query.minPrice ? parseFloat(req.query.minPrice) : null,
        maxPrice: req.query.maxPrice ? parseFloat(req.query.maxPrice) : null
      };
      
      const services = await consumerService.getServices(filters);
      
      // 응답 형식 변경: data -> services (복수형)
      // 필드명은 snake_case로 변환
      const formattedServices = services.map(service => ({
        id: service.id,
        name: service.name,
        description: service.description,
        price: service.price,
        duration: service.duration,
        category: service.category,
        is_active: service.isActive,
        created_at: service.createdAt,
        updated_at: service.updatedAt
      }));
      
      return res.status(200).json({
        success: true,
        services: formattedServices
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch services',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Get service by ID
   */
  getServiceById: async (req, res) => {
    try {
      const { serviceId } = req.params;
      const service = await consumerService.getServiceById(serviceId);
      
      // 응답 형식 변경: data -> service (단수형)
      // 필드명은 snake_case로 변환
      const formattedService = {
        id: service.id,
        name: service.name,
        description: service.description,
        price: service.price,
        duration: service.duration,
        category: service.category,
        is_active: service.isActive,
        created_at: service.createdAt,
        updated_at: service.updatedAt
      };
      
      return res.status(200).json({
        success: true,
        service: formattedService
      });
    } catch (error) {
      return res.status(error.message === 'Service not found' ? 404 : 500).json({
        success: false,
        error: {
          message: error.message || 'Failed to fetch service',
          details: error.message
        }
      });
    }
  },
  
  /**
   * Get all service categories
   */
  getServiceCategories: async (req, res) => {
    try {
      // 서비스 카테고리 목록 - 실제로는 데이터베이스에서 가져와야 함
      const categories = [
        { id: "cleaning", name: "청소" },
        { id: "laundry", name: "세탁" },
        { id: "dishes", name: "설거지" },
        { id: "kitchen", name: "주방 정리" },
        { id: "bathroom", name: "화장실 청소" },
        { id: "deepcleaning", name: "특수 청소" }
      ];
      
      return res.status(200).json({
        success: true,
        categories: categories
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        error: {
          message: 'Failed to fetch service categories',
          details: error.message
        }
      });
    }
  }
};

module.exports = serviceController;