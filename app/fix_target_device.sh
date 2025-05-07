#!/bin/bash

# Switch HomeCleaningApp project to target iOS Simulator
cd "$(dirname "$0")"

# Get the current directory path
PROJECT_DIR=$(pwd)
PROJECT_FILE="$PROJECT_DIR/HomeCleaningApp.xcodeproj/project.pbxproj"

# Backup original project file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"

# Modify project file to target iOS Simulator
# 1. Change SDKROOT to iphonesimulator
sed -i '' 's/SDKROOT = iphoneos;/SDKROOT = iphonesimulator;/g' "$PROJECT_FILE"

# 2. Change TARGETED_DEVICE_FAMILY to include Mac
sed -i '' 's/TARGETED_DEVICE_FAMILY = "1,2";/TARGETED_DEVICE_FAMILY = "1,2,6";/g' "$PROJECT_FILE"

# 3. Disable code signing for simulator
sed -i '' 's/CODE_SIGN_IDENTITY = "iPhone Developer";/CODE_SIGN_IDENTITY = "";/g' "$PROJECT_FILE"
sed -i '' 's/CODE_SIGN_REQUIRED = YES;/CODE_SIGN_REQUIRED = NO;/g' "$PROJECT_FILE"
sed -i '' 's/PROVISIONING_PROFILE_SPECIFIER = .*/PROVISIONING_PROFILE_SPECIFIER = "";/g' "$PROJECT_FILE"

# 4. Set SUPPORTS_MACCATALYST to YES
sed -i '' 's/SUPPORTS_MACCATALYST = NO;/SUPPORTS_MACCATALYST = YES;/g' "$PROJECT_FILE"

echo "Project settings modified to target iOS Simulator"
echo "Build the project with: xcodebuild -project $PROJECT_DIR/HomeCleaningApp.xcodeproj -scheme HomeCleaningApp -destination 'platform=iOS Simulator,name=iPhone 15' build"