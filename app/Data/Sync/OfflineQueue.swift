import Foundation

// 오프라인 작업 타입
enum OfflineOperationType: String, Codable {
    case create
    case update
    case delete
}

// 오프라인 작업 모델
struct OfflineOperation: Codable {
    let id: String
    let type: OfflineOperationType
    let entityType: String
    let entityId: String
    let data: Data?
    let timestamp: Date
    
    init(type: OfflineOperationType, entityType: String, entityId: String, data: Data? = nil) {
        self.id = UUID().uuidString
        self.type = type
        self.entityType = entityType
        self.entityId = entityId
        self.data = data
        self.timestamp = Date()
    }
}

class OfflineQueue {
    static let shared = OfflineQueue()
    
    // 의존성 주입
    private let databaseManager = DatabaseManager.shared
    private let offlineQueueKey = "offline_operations_queue"
    
    private init() {
        // 큐 초기화
        if getQueue() == nil {
            let success = saveQueue([])
            if !success {
                print("OfflineQueue - Failed to initialize empty queue")
            }
        }
    }
    
    // 큐 불러오기
    private func getQueue() -> [OfflineOperation]? {
        return databaseManager.load(forKey: offlineQueueKey)
    }
    
    // 큐 저장
    private func saveQueue(_ queue: [OfflineOperation]) -> Bool {
        return databaseManager.save(queue, forKey: offlineQueueKey)
    }
    
    // 오프라인 작업 추가
    func enqueue(operation: OfflineOperation) -> Bool {
        guard var queue = getQueue() else {
            return saveQueue([operation])
        }
        
        queue.append(operation)
        return saveQueue(queue)
    }
    
    // 첫번째 작업 반환 (큐에서 제거)
    func dequeue() -> OfflineOperation? {
        guard var queue = getQueue(), !queue.isEmpty else {
            return nil
        }
        
        let operation = queue.removeFirst()
        let success = saveQueue(queue)
        
        if !success {
            print("OfflineQueue - Failed to save queue after removing operation")
            // 실패 시 큐를 원상태로 복원하는 로직을 추가할 수도 있음
        }
        
        return operation
    }
    
    // 큐에서 작업 제거
    func remove(operationId: String) -> Bool {
        guard var queue = getQueue() else {
            return false
        }
        
        queue.removeAll { $0.id == operationId }
        return saveQueue(queue)
    }
    
    // 작업 수 반환
    func count() -> Int {
        return getQueue()?.count ?? 0
    }
    
    // 큐가 비어있는지 확인
    func isEmpty() -> Bool {
        return count() == 0
    }
    
    // 모든 작업 불러오기
    func getAllOperations() -> [OfflineOperation] {
        return getQueue() ?? []
    }
    
    // 큐 비우기
    func clear() -> Bool {
        return saveQueue([])
    }
    
    // 특정 타입의 오프라인 작업으로 변환하는 메서드
    func createOperation<T: Codable>(type: OfflineOperationType, entityType: String, entityId: String, object: T? = nil) -> OfflineOperation? {
        var data: Data? = nil
        
        if let object = object {
            do {
                let encoder = JSONEncoder()
                data = try encoder.encode(object)
            } catch {
                print("OfflineQueue - Failed to encode object: \(error.localizedDescription)")
                return nil
            }
        }
        
        return OfflineOperation(type: type, entityType: entityType, entityId: entityId, data: data)
    }
}