/**
 * @fileoverview 응답 형식 표준화 유틸리티
 * 
 * 모든 마이크로서비스에서 일관된 응답 형식을 사용할 수 있도록 유틸리티 함수를 제공합니다.
 * 
 * @module Shared/utils/response
 */

/**
 * 성공 응답 생성
 * 
 * @param {Object} data - 응답 데이터
 * @param {string} [message='Success'] - 성공 메시지
 * @param {number} [statusCode=200] - HTTP 상태 코드
 * @returns {Object} 표준화된 성공 응답 객체
 */
const success = (data, message = 'Success', statusCode = 200) => {
  return {
    status: statusCode,
    body: {
      success: true,
      message,
      data,
    },
  };
};

/**
 * 오류 응답 생성
 * 
 * @param {string} message - 오류 메시지
 * @param {number} [statusCode=500] - HTTP 상태 코드
 * @param {Object} [details=null] - 상세 오류 정보
 * @param {string} [errorCode=null] - 오류 코드
 * @returns {Object} 표준화된 오류 응답 객체
 */
const error = (message, statusCode = 500, details = null, errorCode = null) => {
  return {
    status: statusCode,
    body: {
      success: false,
      error: {
        message,
        details: details || message,
        code: errorCode || 'ERROR',
      },
    },
  };
};

/**
 * 페이지네이션된 데이터 응답 생성
 * 
 * @param {Array} items - 페이지네이션된 항목 목록
 * @param {number} total - 전체 항목 수
 * @param {number} page - 현재 페이지 번호
 * @param {number} limit - 페이지당 항목 수
 * @param {string} [message='Success'] - 성공 메시지
 * @returns {Object} 표준화된 페이지네이션 응답 객체
 */
const paginated = (items, total, page, limit, message = 'Success') => {
  const totalPages = Math.ceil(total / limit);
  
  return {
    status: 200,
    body: {
      success: true,
      message,
      data: items,
      pagination: {
        total,
        page,
        limit,
        total_pages: totalPages,
        has_next_page: page < totalPages,
        has_prev_page: page > 1,
      },
    },
  };
};

/**
 * Express 응답 객체에 응답 전송
 * 
 * @param {Object} res - Express 응답 객체
 * @param {Object} response - 응답 객체 (success, error, paginated 함수 반환값)
 * @returns {Object} Express 응답 객체
 */
const send = (res, response) => {
  return res.status(response.status).json(response.body);
};

/**
 * camelCase 객체를 snake_case 객체로 변환
 * iOS 클라이언트 호환성을 위해 사용
 * 
 * @param {Object|Array} data - 변환할 데이터 객체 또는 배열
 * @returns {Object|Array} snake_case로 변환된 데이터
 */
const toSnakeCase = (data) => {
  if (data === null || data === undefined) {
    return data;
  }
  
  // 배열인 경우 각 항목에 재귀 적용
  if (Array.isArray(data)) {
    return data.map(item => toSnakeCase(item));
  }
  
  // 객체가 아닌 경우 그대로 반환
  if (typeof data !== 'object') {
    return data;
  }
  
  // 객체인 경우 각 속성을 변환
  const result = {};
  
  Object.keys(data).forEach(key => {
    // 키를 snake_case로 변환
    const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
    
    // 값이 객체 또는 배열인 경우 재귀 처리
    const value = (typeof data[key] === 'object' && data[key] !== null) 
      ? toSnakeCase(data[key])
      : data[key];
    
    result[snakeKey] = value;
  });
  
  return result;
};

/**
 * snake_case 객체를 camelCase 객체로 변환
 * 
 * @param {Object|Array} data - 변환할 데이터 객체 또는 배열
 * @returns {Object|Array} camelCase로 변환된 데이터
 */
const toCamelCase = (data) => {
  if (data === null || data === undefined) {
    return data;
  }
  
  // 배열인 경우 각 항목에 재귀 적용
  if (Array.isArray(data)) {
    return data.map(item => toCamelCase(item));
  }
  
  // 객체가 아닌 경우 그대로 반환
  if (typeof data !== 'object') {
    return data;
  }
  
  // 객체인 경우 각 속성을 변환
  const result = {};
  
  Object.keys(data).forEach(key => {
    // 키를 camelCase로 변환
    const camelKey = key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
    
    // 값이 객체 또는 배열인 경우 재귀 처리
    const value = (typeof data[key] === 'object' && data[key] !== null) 
      ? toCamelCase(data[key])
      : data[key];
    
    result[camelKey] = value;
  });
  
  return result;
};

module.exports = {
  success,
  error,
  paginated,
  send,
  toSnakeCase,
  toCamelCase,
};