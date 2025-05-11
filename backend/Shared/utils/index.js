/**
 * @fileoverview 공통 유틸리티 함수 모음
 * 
 * 모든 마이크로서비스에서 공통으로 사용할 수 있는 유틸리티 함수들을 제공합니다.
 * 
 * @module Shared/utils
 */

/**
 * 숫자 포맷팅 유틸리티
 * 
 * 숫자를 포맷팅하는 다양한 유틸리티 함수를 제공합니다.
 */
const numberUtils = {
  /**
   * 숫자에 천 단위 구분 기호를 추가합니다.
   * 
   * @param {number} num - 포맷할 숫자
   * @param {string} [locale='ko-KR'] - 사용할 로케일
   * @returns {string} 포맷된 문자열
   */
  formatWithCommas: (num, locale = 'ko-KR') => {
    return num.toLocaleString(locale);
  },

  /**
   * 숫자를 통화 형식으로 포맷팅합니다.
   * 
   * @param {number} num - 포맷할 숫자
   * @param {string} [currency='KRW'] - 통화 코드
   * @param {string} [locale='ko-KR'] - 사용할 로케일
   * @returns {string} 포맷된 문자열
   */
  formatCurrency: (num, currency = 'KRW', locale = 'ko-KR') => {
    return new Intl.NumberFormat(locale, {
      style: 'currency',
      currency: currency,
    }).format(num);
  },

  /**
   * 숫자를 지정된 소수점 자릿수로 반올림합니다.
   * 
   * @param {number} num - 포맷할 숫자
   * @param {number} [decimals=2] - 소수점 자릿수
   * @returns {number} 반올림된 숫자
   */
  round: (num, decimals = 2) => {
    return Number(Math.round(num + 'e' + decimals) + 'e-' + decimals);
  },
};

/**
 * 문자열 유틸리티
 * 
 * 문자열 처리에 관련된 유틸리티 함수들을 제공합니다.
 */
const stringUtils = {
  /**
   * 문자열의 첫 글자를 대문자로 변환합니다.
   * 
   * @param {string} str - 변환할 문자열
   * @returns {string} 변환된 문자열
   */
  capitalize: (str) => {
    if (!str || typeof str !== 'string') return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
  },

  /**
   * 문자열을 카멜 케이스로 변환합니다.
   * 
   * @param {string} str - 변환할 문자열
   * @returns {string} 카멜 케이스 문자열
   */
  toCamelCase: (str) => {
    if (!str || typeof str !== 'string') return '';
    return str
      .replace(/(?:^\w|[A-Z]|\b\w)/g, (word, index) => {
        return index === 0 ? word.toLowerCase() : word.toUpperCase();
      })
      .replace(/\s+|[-_]/g, '');
  },

  /**
   * 문자열을 스네이크 케이스로 변환합니다.
   * 
   * @param {string} str - 변환할 문자열
   * @returns {string} 스네이크 케이스 문자열
   */
  toSnakeCase: (str) => {
    if (!str || typeof str !== 'string') return '';
    return str
      .replace(/\s+/g, '_')
      .replace(/([A-Z])/g, '_$1')
      .toLowerCase()
      .replace(/^_/, '');
  },

  /**
   * 문자열을 마스킹합니다.
   * 
   * @param {string} str - 마스킹할 문자열
   * @param {number} [visibleStart=1] - 시작부분에 표시할 문자 수
   * @param {number} [visibleEnd=1] - 끝부분에 표시할 문자 수
   * @param {string} [maskChar='*'] - 마스킹 문자
   * @returns {string} 마스킹된 문자열
   */
  mask: (str, visibleStart = 1, visibleEnd = 1, maskChar = '*') => {
    if (!str || typeof str !== 'string') return '';
    if (str.length <= visibleStart + visibleEnd) return str;
    
    const start = str.slice(0, visibleStart);
    const end = str.slice(-visibleEnd);
    const masked = maskChar.repeat(str.length - visibleStart - visibleEnd);
    
    return start + masked + end;
  },
};

/**
 * 날짜 유틸리티
 * 
 * 날짜 처리에 관련된 유틸리티 함수들을 제공합니다.
 */
const dateUtils = {
  /**
   * 날짜를 지정된 형식의 문자열로 포맷팅합니다.
   * 
   * @param {Date|string|number} date - 포맷할 날짜
   * @param {string} [format='YYYY-MM-DD'] - 날짜 형식
   * @returns {string} 포맷된 날짜 문자열
   */
  format: (date, format = 'YYYY-MM-DD') => {
    const d = new Date(date);
    
    if (isNaN(d.getTime())) {
      return 'Invalid Date';
    }
    
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');
    const seconds = String(d.getSeconds()).padStart(2, '0');
    
    return format
      .replace('YYYY', year)
      .replace('MM', month)
      .replace('DD', day)
      .replace('HH', hours)
      .replace('mm', minutes)
      .replace('ss', seconds);
  },

  /**
   * 두 날짜 사이의 일수 차이를 계산합니다.
   * 
   * @param {Date|string|number} date1 - 첫 번째 날짜
   * @param {Date|string|number} date2 - 두 번째 날짜
   * @returns {number} 일수 차이
   */
  daysBetween: (date1, date2) => {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    
    if (isNaN(d1.getTime()) || isNaN(d2.getTime())) {
      return 0;
    }
    
    // 시간, 분, 초, 밀리초를 제거하여 날짜만 비교
    d1.setHours(0, 0, 0, 0);
    d2.setHours(0, 0, 0, 0);
    
    // 밀리초 단위 차이를 일 단위로 변환
    return Math.round((d2 - d1) / (1000 * 60 * 60 * 24));
  },

  /**
   * 날짜에 일수를 더합니다.
   * 
   * @param {Date|string|number} date - 기준 날짜
   * @param {number} days - 더할 일수
   * @returns {Date} 계산된 새 날짜
   */
  addDays: (date, days) => {
    const d = new Date(date);
    d.setDate(d.getDate() + days);
    return d;
  },

  /**
   * 두 날짜가 같은 날인지 확인합니다.
   * 
   * @param {Date|string|number} date1 - 첫 번째 날짜
   * @param {Date|string|number} date2 - 두 번째 날짜
   * @returns {boolean} 같은 날이면 true
   */
  isSameDay: (date1, date2) => {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    return (
      d1.getFullYear() === d2.getFullYear() &&
      d1.getMonth() === d2.getMonth() &&
      d1.getDate() === d2.getDate()
    );
  },
};

/**
 * 유효성 검사 유틸리티
 * 
 * 자주 사용되는 유효성 검사 함수들을 제공합니다.
 */
const validateUtils = {
  /**
   * 이메일 주소 유효성을 검사합니다.
   * 
   * @param {string} email - 검사할 이메일 주소
   * @returns {boolean} 유효하면 true
   */
  isEmail: (email) => {
    if (!email || typeof email !== 'string') return false;
    const regex = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return regex.test(email.toLowerCase());
  },

  /**
   * 전화번호 유효성을 검사합니다.
   * 
   * @param {string} phone - 검사할 전화번호
   * @returns {boolean} 유효하면 true
   */
  isPhone: (phone) => {
    if (!phone || typeof phone !== 'string') return false;
    // 대한민국 전화번호 형식에 맞는 정규식 (02-XXXX-XXXX 또는 010-XXXX-XXXX 등)
    const regex = /^(0[2-8][0-9]|01[0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$/;
    return regex.test(phone);
  },

  /**
   * 값이 비어있는지 검사합니다.
   * 
   * @param {*} value - 검사할 값
   * @returns {boolean} 비어있으면 true
   */
  isEmpty: (value) => {
    if (value === null || value === undefined) return true;
    if (typeof value === 'string') return value.trim() === '';
    if (Array.isArray(value)) return value.length === 0;
    if (typeof value === 'object') return Object.keys(value).length === 0;
    return false;
  },

  /**
   * 주어진 값이 숫자인지 검사합니다.
   * 
   * @param {*} value - 검사할 값
   * @returns {boolean} 숫자면 true
   */
  isNumber: (value) => {
    if (typeof value === 'number') return !isNaN(value);
    if (typeof value === 'string' && value.trim() !== '') {
      return !isNaN(Number(value));
    }
    return false;
  },
};

/**
 * 일반 유틸리티 함수
 * 
 * 다양한 유틸리티 함수들을 제공합니다.
 */
const generalUtils = {
  /**
   * 고유 ID를 생성합니다.
   * 
   * @param {number} [length=10] - ID 길이
   * @returns {string} 생성된 고유 ID
   */
  generateId: (length = 10) => {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  },

  /**
   * 깊은 객체 복사를 수행합니다.
   * 
   * @param {Object} obj - 복사할 객체
   * @returns {Object} 복사된 객체
   */
  deepCopy: (obj) => {
    if (obj === null || typeof obj !== 'object') return obj;
    return JSON.parse(JSON.stringify(obj));
  },

  /**
   * 두 객체를 깊게 병합합니다.
   * 
   * @param {Object} target - 대상 객체
   * @param {Object} source - 소스 객체
   * @returns {Object} 병합된 객체
   */
  deepMerge: (target, source) => {
    if (!source) return target;
    
    const output = { ...target };
    
    Object.keys(source).forEach((key) => {
      if (source[key] instanceof Object && key in target && target[key] instanceof Object) {
        output[key] = generalUtils.deepMerge(target[key], source[key]);
      } else {
        output[key] = source[key];
      }
    });
    
    return output;
  },

  /**
   * 배열에서 고유한 값들만 추출합니다.
   * 
   * @param {Array} array - 입력 배열
   * @returns {Array} 중복이 제거된 배열
   */
  uniqueArray: (array) => {
    if (!Array.isArray(array)) return [];
    return [...new Set(array)];
  },

  /**
   * 객체에서 지정된 키들만 선택합니다.
   * 
   * @param {Object} obj - 입력 객체
   * @param {Array<string>} keys - 선택할 키 배열
   * @returns {Object} 선택된 키만 포함한 객체
   */
  pick: (obj, keys) => {
    if (!obj || typeof obj !== 'object' || !Array.isArray(keys)) return {};
    
    return keys.reduce((result, key) => {
      if (key in obj) {
        result[key] = obj[key];
      }
      return result;
    }, {});
  },

  /**
   * 객체에서 지정된 키들을 제외합니다.
   * 
   * @param {Object} obj - 입력 객체
   * @param {Array<string>} keys - 제외할 키 배열
   * @returns {Object} 키가 제외된 객체
   */
  omit: (obj, keys) => {
    if (!obj || typeof obj !== 'object' || !Array.isArray(keys)) return obj;
    
    return Object.keys(obj).reduce((result, key) => {
      if (!keys.includes(key)) {
        result[key] = obj[key];
      }
      return result;
    }, {});
  },
};

const response = require('./response');

module.exports = {
  numberUtils,
  stringUtils,
  dateUtils,
  validateUtils,
  generalUtils,
  response,
};