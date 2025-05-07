#!/bin/bash

# 이 스크립트는 Pod 관련 문제를 해결하기 위해 프로젝트를 정리하고 다시 빌드합니다
cd "$(dirname "$0")"

echo "1. Pod 캐시 및 중간 파일 제거"
rm -rf ~/Library/Developer/Xcode/DerivedData/HomeCleaningApp-*
rm -rf Pods
rm -rf Podfile.lock

echo "2. CocoaPods 재설치"
pod deintegrate
pod setup
pod install --repo-update

echo "3. 프로젝트 설정 업데이트"
# 프로젝트 설정에서 SWIFT_VERSION을 확인하고 업데이트
sed -i '' 's/SWIFT_VERSION = 5.0;/SWIFT_VERSION = 5.9;/g' HomeCleaningApp.xcodeproj/project.pbxproj

# 모든 IPHONEOS_DEPLOYMENT_TARGET을 18.2로 설정
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 18.0;/IPHONEOS_DEPLOYMENT_TARGET = 18.2;/g' HomeCleaningApp.xcodeproj/project.pbxproj

# SDKROOT를 iphonesimulator로 설정
sed -i '' 's/SDKROOT = iphoneos;/SDKROOT = iphonesimulator;/g' HomeCleaningApp.xcodeproj/project.pbxproj

# 코드 서명 비활성화
sed -i '' 's/CODE_SIGN_IDENTITY = "iPhone Developer";/CODE_SIGN_IDENTITY = "";/g' HomeCleaningApp.xcodeproj/project.pbxproj
sed -i '' 's/CODE_SIGN_REQUIRED = YES;/CODE_SIGN_REQUIRED = NO;/g' HomeCleaningApp.xcodeproj/project.pbxproj
sed -i '' 's/PROVISIONING_PROFILE_SPECIFIER = .*/PROVISIONING_PROFILE_SPECIFIER = "";/g' HomeCleaningApp.xcodeproj/project.pbxproj

# Mac Catalyst 지원 활성화
sed -i '' 's/SUPPORTS_MACCATALYST = NO;/SUPPORTS_MACCATALYST = YES;/g' HomeCleaningApp.xcodeproj/project.pbxproj

echo "4. 프로젝트 빌드"
xcodebuild clean -workspace HomeCleaningApp.xcworkspace -scheme HomeCleaningApp
xcodebuild -workspace HomeCleaningApp.xcworkspace -scheme HomeCleaningApp -destination 'platform=iOS Simulator,name=iPhone 15' -configuration Debug build

echo "빌드 완료! 오류가 발생한 경우 로그를 확인하세요."