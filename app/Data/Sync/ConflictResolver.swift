import Foundation

// 충돌 타입 정의
enum ConflictType {
    case localNewer
    case remoteNewer
    case sameTimestamp
    case unknown
}

// 충돌 해결 전략
enum ConflictResolutionStrategy {
    case useLocal
    case useRemote
    case merge
    case askUser
}

class ConflictResolver {
    static let shared = ConflictResolver()
    
    private init() {}
    
    // 충돌 유형 파악
    func determineConflictType<T: Codable>(localData: T, remoteData: T, localTimestamp: Date, remoteTimestamp: Date) -> ConflictType {
        let timeComparison = localTimestamp.compare(remoteTimestamp)
        
        switch timeComparison {
        case .orderedDescending:
            return .localNewer
        case .orderedAscending:
            return .remoteNewer
        case .orderedSame:
            return .sameTimestamp
        }
    }
    
    // 충돌 해결 전략 결정
    func determineResolutionStrategy(forConflictType conflictType: ConflictType) -> ConflictResolutionStrategy {
        switch conflictType {
        case .localNewer:
            return .useLocal
        case .remoteNewer:
            return .useRemote
        case .sameTimestamp, .unknown:
            // 더 복잡한 로직으로 대체 가능, 예를 들어 사용자에게 선택 요청
            return .merge
        }
    }
    
    // 충돌 해결 (실제 구현)
    func resolveConflict<T: Codable>(local: T, remote: T, localTimestamp: Date, remoteTimestamp: Date) -> T {
        let conflictType = determineConflictType(localData: local, remoteData: remote, localTimestamp: localTimestamp, remoteTimestamp: remoteTimestamp)
        let strategy = determineResolutionStrategy(forConflictType: conflictType)
        
        switch strategy {
        case .useLocal:
            return local
        case .useRemote:
            return remote
        case .merge, .askUser:
            // 이후 실제 머지 로직으로 대체 필요
            return conflictType == .localNewer ? local : remote
        }
    }
}