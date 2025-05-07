import Foundation
import Combine

class ConnectivityState: ObservableObject {
    static let shared = ConnectivityState()
    
    // 네트워크 모니터 인스턴스
    private let networkMonitor = NetworkMonitor.shared
    
    // 발행자 (Publisher) 선언
    @Published var isConnected: Bool = true
    @Published var connectionType: NetworkMonitor.ConnectionType = .unknown
    @Published var connectionStatusMessage: String = "연결됨"
    
    // 구독자 저장소
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // 네트워크 상태 변경 이벤트 구독
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        // 네트워크 상태 변경 이벤트에 대한 콜백 설정
        networkMonitor.onStatusChange = { [weak self] isConnected in
            guard let self = self else { return }
            
            // 앱 상태 업데이트
            self.isConnected = isConnected
            self.connectionType = self.networkMonitor.connectionType
            self.connectionStatusMessage = self.networkMonitor.getStatusString()
            
            // 네트워크 상태 변경에 따른 추가 액션
            if isConnected {
                self.handleNetworkConnected()
            } else {
                self.handleNetworkDisconnected()
            }
        }
    }
    
    // 네트워크 연결 시 호출될 함수
    private func handleNetworkConnected() {
        print("네트워크 연결됨 - 액션 실행")
        // 앱이 네트워크 연결을 다시 획득했을 때 수행할 작업
        // 예: 동기화 시작, 오프라인 대기열 처리 등
    }
    
    // 네트워크 연결 끊김 시 호출될 함수
    private func handleNetworkDisconnected() {
        print("네트워크 연결 끊김 - 액션 실행")
        // 앱이 네트워크 연결을 잃었을 때 수행할 작업
        // 예: 오프라인 모드로 전환, 사용자에게 알림 등
    }
    
    // 현재 네트워크 상태 확인 도우미 함수
    func checkNetworkAndContinue(completion: @escaping (Bool) -> Void) {
        if isConnected {
            completion(true)
        } else {
            // 네트워크 없음 알림 표시 (앱의 알림 표시 로직에 맞게 수정 필요)
            print("네트워크 연결 없음 알림")
            completion(false)
        }
    }
    
    // 백그라운드 동기화 필요 여부 확인
    func needsBackgroundSync() -> Bool {
        // 이전에 네트워크 연결이 끊긴 상태에서 작업이 있었는지 확인
        // 예: 오프라인 작업 큐에 항목이 있는지 확인
        return false // 임시 구현
    }
}