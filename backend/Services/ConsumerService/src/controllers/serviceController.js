const consumerService = require('../services/consumerService');
const { validationResult } = require('express-validator');

/**
 * Controller for handling service-related requests
 */
const serviceController = {
  /**
   * Get all services with pagination
   */
  getAllServices: async (req, res) => {
    try {
      // Extract filters
      const filters = {
        category: req.query.category,
        minPrice: req.query.minPrice ? parseFloat(req.query.minPrice) : null,
        maxPrice: req.query.maxPrice ? parseFloat(req.query.maxPrice) : null
      };
      
      // Extract pagination parameters
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 20;
      
      // Get paginated services
      const result = await consumerService.getServices(filters, page, limit);
      
      // 응답 형식 변경: data -> services (복수형)
      // 필드명은 snake_case로 변환
      const formattedServices = result.services.map(service => ({
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
        services: formattedServices,
        pagination: result.pagination
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
        { 
          id: "cleaning", 
          name: "청소", 
          description: "일반적인 가정 청소 서비스입니다. 먼지제거, 바닥 청소 등이 포함됩니다."
        },
        { 
          id: "laundry", 
          name: "세탁", 
          description: "의류 세탁 및 건조 서비스를 제공합니다." 
        },
        { 
          id: "dishes", 
          name: "설거지", 
          description: "그릇 세척 및 주방 청소 서비스입니다." 
        },
        { 
          id: "kitchen", 
          name: "주방 정리", 
          description: "주방 공간 전체 청소 및 정리 서비스입니다." 
        },
        { 
          id: "bathroom", 
          name: "화장실 청소", 
          description: "화장실 청소 및 소독 서비스를 제공합니다." 
        },
        { 
          id: "deepcleaning", 
          name: "특수 청소", 
          description: "얼룩 제거, 세균 소독 등 특수 청소 서비스입니다." 
        }
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