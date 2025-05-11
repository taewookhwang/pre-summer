const js = require('@eslint/js');
const prettier = require('eslint-plugin-prettier');
const prettierConfig = require('eslint-config-prettier');
const jsdoc = require('eslint-plugin-jsdoc');

module.exports = [
  js.configs.recommended,
  prettierConfig,
  {
    plugins: {
      prettier,
      jsdoc,
    },
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'commonjs',
      globals: {
        process: 'readonly',
        jest: 'readonly',
        describe: 'readonly',
        test: 'readonly',
        expect: 'readonly',
        beforeEach: 'readonly',
        afterEach: 'readonly',
        console: 'readonly',
        module: 'readonly',
        exports: 'readonly',
        require: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
      },
    },
    rules: {
      // JSDoc 규칙
      'jsdoc/require-jsdoc': ['warn', {
        require: {
          FunctionDeclaration: true,
          MethodDefinition: true,
          ClassDeclaration: true,
          ArrowFunctionExpression: false,
          FunctionExpression: false,
        },
      }],
      'jsdoc/require-param-description': 'warn',
      'jsdoc/require-returns-description': 'warn',
      'jsdoc/require-param-type': 'warn',
      'jsdoc/require-returns-type': 'warn',
      'jsdoc/valid-types': 'warn',

      'no-undef': 'warn',
      'no-useless-escape': 'warn',
      'no-control-regex': 'warn',
      // 에러 관련 규칙
      'no-console': 'off', // 모든 환경에서 console 사용 허용
      'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off', // 프로덕션에서는 debugger 사용 금지

      // 코드 스타일 규칙
      indent: 'off', // 들여쓰기 체크 비활성화
      'linebreak-style': ['error', 'unix'], // 줄바꿈 유닉스 스타일 사용
      quotes: ['error', 'single', { avoidEscape: true }], // 작은따옴표 사용
      semi: ['error', 'always'], // 항상 세미콜론 사용

      // ES6 관련 규칙
      'arrow-parens': ['error', 'always'], // 화살표 함수 매개변수는 항상 괄호로 감싸기
      'arrow-spacing': ['error', { before: true, after: true }], // 화살표 함수의 화살표 주위에 공백
      'prefer-const': 'warn', // 재할당 없는 변수는 const 사용
      'prefer-template': 'warn', // 문자열 연결에 템플릿 리터럴 사용

      // 객체 및 배열 관련 규칙
      'object-curly-spacing': ['error', 'always'], // 객체 중괄호 내부에 공백
      'array-bracket-spacing': ['error', 'never'], // 배열 대괄호 내부에 공백 없음
      'comma-dangle': ['error', 'always-multiline'], // 여러 줄의 배열/객체는 마지막 항목에 콤마

      // 함수 관련 규칙
      'func-style': 'off', // 함수 선언문과 표현식 모두 허용
      'no-var': 'error', // var 대신 let/const 사용

      // 기타 규칙
      'no-unused-vars': 'warn', // 사용하지 않는 변수는 경고만 표시
      'max-len': [
        'error',
        {
          code: 100,
          ignoreComments: true,
          ignoreStrings: true,
          ignoreTemplateLiterals: true,
          ignoreUrls: true,
        },
      ], // 한 줄 최대 길이 제한 (100자)
      'prettier/prettier': 'warn',
    },
  },
  {
    ignores: [
      'node_modules/**',
      'dist/**',
      'build/**',
      'coverage/**',
      '*.json',
      '*.md',
      '*.yml',
      '*.yaml',
      '*.config.js',
      '*.config.cjs',
      '.*',
    ],
  },
];
