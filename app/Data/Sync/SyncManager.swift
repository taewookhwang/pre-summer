import Foundation
import Network

// 동기화 상태
enum SyncStatus {
    case idle
    case syncing
    case completed
    case failed(Error)
}

// 동기화 결과
struct SyncResult {
    let syncedCount: Int
    let failedCount: Int
    let timestamp: Date
}

class SyncManager {
    static let shared = SyncManager()
    
    // 의존성
    private let offlineQueue = OfflineQueue.shared
    private let conflictResolver = ConflictResolver.shared
    
    // 상태
    private(set) var status: SyncStatus = .idle
    private(set) var lastSyncResult: SyncResult?
    private(set) var lastSyncTime: Date?
    
    // 네트워크 모니터링
    private let networkMonitor = NWPathMonitor()
    private(set) var isOnline = true
    
    // 콜백
    var syncStatusChanged: ((SyncStatus) -> Void)?
    var networkStatusChanged: ((Bool) -> Void)?
    
    private init() {
        setupNetworkMonitoring()
    }
    
    // 네트워크 모니터링 설정
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            let isOnline = path.status == .satisfied
            
            DispatchQueue.main.async {
                self?.isOnline = isOnline
                self?.networkStatusChanged?(isOnline)
                
                // 온라인으로 전환되면 자동 동기화 시도
                if isOnline {
                    self?.attemptAutoSync()
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        networkMonitor.start(queue: queue)
    }
    
    // 자동 동기화 시도
    private func attemptAutoSync() {
        if offlineQueue.count() > 0 {
            syncPendingOperations()
        }
    }
    
    // 대기 중인 작업 동기화
    func syncPendingOperations(completion: ((SyncResult) -> Void)? = nil) {
        guard isOnline else {
            updateStatus(.failed(NSError(domain: "SyncManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Device is offline"])))
            let result = SyncResult(syncedCount: 0, failedCount: offlineQueue.count(), timestamp: Date())
            completion?(result)
            return
        }
        
        updateStatus(.syncing)
        
        let operations = offlineQueue.getAllOperations()
        guard !operations.isEmpty else {
            updateStatus(.completed)
            let result = SyncResult(syncedCount: 0, failedCount: 0, timestamp: Date())
            lastSyncResult = result
            lastSyncTime = result.timestamp
            completion?(result)
            return
        }
        
        // 실제 구현은 실제 API 호출을 해야 함
        var syncedCount = 0
        var failedCount = 0
        
        // 테스트 목적으로 임의의 성공률을 사용하여 시뮬레이션
        for operation in operations {
            // 테스트로 10개 중 9개는 성공, 1개는 실패하는 것으로 가정함
            if Int.random(in: 0...9) < 9 {
                offlineQueue.remove(operationId: operation.id)
                syncedCount += 1
            } else {
                failedCount += 1
            }
        }
        
        let result = SyncResult(syncedCount: syncedCount, failedCount: failedCount, timestamp: Date())
        lastSyncResult = result
        lastSyncTime = result.timestamp
        
        updateStatus(failedCount > 0 ? .failed(NSError(domain: "SyncManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "\(failedCount) operations failed to sync"])) : .completed)
        
        completion?(result)
    }
    
    // 상태 업데이트
    private func updateStatus(_ newStatus: SyncStatus) {
        status = newStatus
        syncStatusChanged?(newStatus)
    }
    
    // 네트워크 상태 확인
    func checkNetworkConnection() -> Bool {
        return isOnline
    }
    
    // 수동 동기화 실행
    func performManualSync(completion: @escaping (SyncResult) -> Void) {
        syncPendingOperations(completion: completion)
    }
    
    // 동기화 필요 여부 확인
    func needsSync() -> Bool {
        return !offlineQueue.isEmpty()
    }
    
    // 마지막 동기화 이후 경과 시간 (분)
    func minutesSinceLastSync() -> Int? {
        guard let lastSyncTime = lastSyncTime else {
            return nil
        }
        
        let diffComponents = Calendar.current.dateComponents([.minute], from: lastSyncTime, to: Date())
        return diffComponents.minute
    }
}