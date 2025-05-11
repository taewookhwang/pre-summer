module.exports = {
  // 기본 설정
  printWidth: 100, // 한 줄 최대 길이
  tabWidth: 2, // 탭 간격
  useTabs: false, // 탭 사용 안 함, 스페이스 사용
  semi: true, // 세미콜론 사용
  singleQuote: true, // 작은따옴표 사용

  // 객체, 배열, 함수 설정
  trailingComma: 'all', // 여러 줄일 때 마지막 요소 뒤에 항상 쉼표
  bracketSpacing: true, // 객체 리터럴의 괄호 안에 공백 추가
  arrowParens: 'always', // 화살표 함수의 매개변수 괄호 항상 사용

  // 추가 설정
  quoteProps: 'as-needed', // 필요할 때만 객체 속성 이름에 따옴표 사용
  jsxSingleQuote: false, // JSX에서는 큰따옴표 사용
  endOfLine: 'lf', // 줄 끝은 LF(유닉스 스타일) 사용

  // 특수 파일 설정
  overrides: [
    {
      files: '*.json',
      options: {
        tabWidth: 2,
      },
    },
    {
      files: '*.{yaml,yml}',
      options: {
        tabWidth: 2,
      },
    },
  ],
};
