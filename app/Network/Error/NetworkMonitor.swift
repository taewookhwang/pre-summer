import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private(set) var isConnected: Bool = true
    private(set) var connectionType: ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    // 연결 상태 변경 콜백
    var onStatusChange: ((Bool) -> Void)?
    
    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            self?.connectionType = self?.getConnectionType(from: path) ?? .unknown
            
            // 메인 큐에서 콜백 호출
            if let onStatusChange = self?.onStatusChange {
                DispatchQueue.main.async {
                    onStatusChange(self?.isConnected ?? false)
                }
            }
            
            // 상태 변경 로깅
            DispatchQueue.main.async {
                self?.logNetworkStatus()
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(from path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    private func logNetworkStatus() {
        let status = isConnected ? "연결됨" : "연결 끊김"
        var type = ""
        
        switch connectionType {
        case .wifi:
            type = "WiFi"
        case .cellular:
            type = "Cellular"
        case .ethernet:
            type = "Ethernet"
        case .unknown:
            type = "Unknown"
        }
        
        print("네트워크 상태: \(status), 연결 타입: \(type)")
    }
    
    // 현재 연결 상태 문자열 반환
    func getStatusString() -> String {
        if isConnected {
            switch connectionType {
            case .wifi:
                return "WiFi에 연결됨"
            case .cellular:
                return "모바일 데이터에 연결됨"
            case .ethernet:
                return "유선 네트워크에 연결됨"
            case .unknown:
                return "네트워크에 연결됨"
            }
        } else {
            return "네트워크 연결 없음"
        }
    }
}