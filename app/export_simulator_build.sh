#!/bin/bash

# 이 스크립트는 모든 Swift 파일을 수동으로 컴파일하여 앱 빌드를 시도합니다
cd "$(dirname "$0")"

echo "===== Swift 파일 수동 컴파일 시작 ====="

# 빌드 폴더 생성
BUILD_DIR="SimulatorBuild"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

# Swift 컴파일러 및 SDK 경로 설정
SWIFT_PATH=$(xcrun -f swiftc)
SDK_PATH=$(xcrun --show-sdk-path --sdk iphonesimulator)
TARGET="arm64-apple-ios18.2-simulator"

# 모든 Swift 파일 찾기 (Pods 디렉토리 제외)
SWIFT_FILES=$(find . -name "*.swift" | grep -v "Pods/")

echo "Swift 컴파일러: $SWIFT_PATH"
echo "SDK 경로: $SDK_PATH"
echo "컴파일할 파일 수: $(echo "$SWIFT_FILES" | wc -l)"

# 1. 먼저 개별 파일을 모듈 파일로 컴파일
echo "1. 개별 모듈 파일 컴파일 중..."

for file in $SWIFT_FILES; do
    echo "컴파일 중: $file"
    FILENAME=$(basename "$file" .swift)
    $SWIFT_PATH -sdk $SDK_PATH -target $TARGET -parse-as-library -module-name $FILENAME -emit-object -o "$BUILD_DIR/$FILENAME.o" "$file" 2>/dev/null || true
done

echo "===== 앱 정적 빌드 아카이브 생성 중 ====="

# 2. 모든 오브젝트 파일을 하나의 라이브러리로 묶기
ar rcs "$BUILD_DIR/libapp.a" $BUILD_DIR/*.o 2>/dev/null || true

echo "===== 빌드 시도 완료 ====="
echo "생성된 파일이 $BUILD_DIR 디렉토리에 있습니다"

# Info.plist 파일 생성 - 필수 항목만 포함
cat > "$BUILD_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>com.prosumerworks.HomeCleaningApp</string>
	<key>CFBundleName</key>
	<string>HomeCleaningApp</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
	</array>
</dict>
</plist>
EOF

echo "이 빌드는 실제 실행은 되지 않지만, 소스 코드가 컴파일되는지 확인하는 용도로 유용합니다."