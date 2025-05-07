import Foundation

class PaymentState {
    // MARK: - Types
    
    enum Status {
        case idle
        case loading
        case processing
        case completed
        case error(String)
    }
    
    // MARK: - Properties
    
    private(set) var status: Status = .idle {
        didSet {
            statusDidChange?()
        }
    }
    
    private(set) var currentPayment: Payment?
    private(set) var selectedPaymentMethod: String?
    private(set) var errorMessage: String?
    
    // MARK: - Callbacks
    
    var statusDidChange: (() -> Void)?
    var paymentMethodsUpdated: (() -> Void)?
    var paymentCompleted: ((Payment) -> Void)?
    var paymentFailed: ((String) -> Void)?
    
    // MARK: - Services
    
    // Using our network placeholder class since PaymentService is not available
    private let networkServices = NetworkServices()
    
    // MARK: - Methods
    
    func selectPaymentMethod(_ methodId: String) {
        selectedPaymentMethod = methodId
    }
    
    func processPayment(amount: Double, for reservationId: String) {
        guard let paymentMethod = selectedPaymentMethod else {
            status = .error("결제 방법을 선택해주세요")
            errorMessage = "결제 방법을 선택해주세요"
            paymentFailed?("결제 방법을 선택해주세요")
            return
        }
        
        status = .processing
        
        networkServices.processPayment(
            amount: amount,
            methodId: paymentMethod,
            reservationId: reservationId
        ) { [weak self] (result: Result<Payment, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let payment):
                self.currentPayment = payment
                self.status = .completed
                self.paymentCompleted?(payment)
                
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.status = .error(error.localizedDescription)
                self.paymentFailed?(error.localizedDescription)
            }
        }
    }
    
    func reset() {
        status = .idle
        currentPayment = nil
        errorMessage = nil
    }
}

// Helper class to simulate PaymentService since it doesn't exist
private class NetworkServices {
    func processPayment(amount: Double, methodId: String, reservationId: String, completion: @escaping (Result<Payment, Error>) -> Void) {
        // Simulate network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: DispatchWorkItem(block: {
            // Create a dummy payment result
            let payment = Payment(
                id: Int.random(in: 10000...99999),
                reservationId: Int.random(in: 1000...9999),
                amount: amount,
                status: .completed,
                method: .card, // 기본값으로 카드 결제 사용
                transactionId: "tx_\(UUID().uuidString.prefix(12))",
                timestamp: Date()
            )
            completion(.success(payment))
        }))
    }
}