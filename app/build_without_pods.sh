#!/bin/bash

# Pod 없이 빌드하는 스크립트
cd "$(dirname "$0")"

# Swift 파일 목록 수집
SWIFT_FILES=$(find . -name "*.swift" | grep -v "Pods/")

# 빌드 명령 실행
xcrun swiftc $SWIFT_FILES \
  -sdk $(xcrun --show-sdk-path --sdk iphonesimulator) \
  -target arm64-apple-ios18.2-simulator \
  -o HomeCleaningApp

echo "빌드 완료: HomeCleaningApp"
