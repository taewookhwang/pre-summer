#!/bin/bash

# 이 스크립트는 Podfile을 임시로 수정하여 모든 Pod를 주석 처리하고 빌드합니다
cd "$(dirname "$0")"

echo "===== 임시 빌드 준비 ====="

# 1. Podfile 백업 및 수정
echo "1. Podfile 백업 및 수정"
cp Podfile Podfile.bak

# 모든 'pod' 줄을 주석 처리
sed -i '' 's/^[[:space:]]*pod/# pod/g' Podfile

# 2. Pod 설치 다시 실행
echo "2. Pod 설치 다시 실행"
pod deintegrate
pod install

# 3. ImportKit 우회 파일 생성
echo "3. 라이브러리 우회 파일 생성"
mkdir -p Network/LocalImplementations

cat > Network/LocalImplementations/ImportShims.swift << 'EOF'
import Foundation
import UIKit

// Alamofire 대체
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

enum ParameterEncoding {
    case urlEncoding
    case jsonEncoding
    case multipartFormData
}

// Socket.IO 대체
class SocketManager {
    static let shared = SocketManager()
    
    func socket(forNamespace nsp: String = "/") -> SocketIOClient {
        return SocketIOClient()
    }
}

class SocketIOClient {
    func connect() {}
    func disconnect() {}
    
    func on(_ event: String, callback: @escaping ([Any]) -> Void) -> UUID {
        return UUID()
    }
    
    func emit(_ event: String, _ items: Any...) {}
}

// Firebase 대체
class FirebaseApp {
    static let shared = FirebaseApp()
    static func configure() {}
}

class Auth {
    static let shared = Auth()
    
    func signIn(withEmail email: String, password: String, completion: ((Any?, Error?) -> Void)?) {
        completion?(nil, nil)
    }
}

class Messaging {
    static let shared = Messaging()
    
    func token(completion: @escaping (String?, Error?) -> Void) {
        completion("mock_token", nil)
    }
}
EOF

# 4. 빌드 시도
echo "4. 빌드 시도"
xcodebuild clean -workspace HomeCleaningApp.xcworkspace -scheme HomeCleaningApp
xcodebuild -workspace HomeCleaningApp.xcworkspace -scheme HomeCleaningApp -destination 'platform=iOS Simulator,name=iPhone 16' -configuration Debug build ONLY_ACTIVE_ARCH=YES VALID_ARCHS=arm64

echo "====== 완료 ======"
echo "중요: 테스트 후 'Podfile.bak'을 다시 'Podfile'로 복원하세요:"
echo "mv Podfile.bak Podfile && pod install"