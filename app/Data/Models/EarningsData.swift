import Foundation

/// 기술자 수입 데이터 모델
struct EarningsData: Codable {
    /// 총 수입
    let totalEarnings: Double
    
    /// 완료된 작업 수
    let completedJobs: Int
    
    /// 일별 수입 데이터
    let earnings: [DailyEarning]
    
    enum CodingKeys: String, CodingKey {
        case totalEarnings = "total_earnings"
        case completedJobs = "completed_jobs"
        case earnings
    }
    
    /// Dictionary로 변환하는 메서드
    func toDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        result["total_earnings"] = totalEarnings
        result["completed_jobs"] = completedJobs
        
        var earningsArray: [[String: Any]] = []
        for earning in earnings {
            earningsArray.append(earning.toDictionary())
        }
        result["earnings"] = earningsArray
        
        return result
    }
}

/// 일별 수입 데이터 모델
struct DailyEarning: Codable {
    /// 날짜 (YYYY-MM-DD 형식)
    let date: String
    
    /// 해당 일자 수입 금액
    let amount: Double
    
    /// 해당 일자 작업 수
    let jobCount: Int
    
    enum CodingKeys: String, CodingKey {
        case date, amount
        case jobCount = "job_count"
    }
    
    /// Dictionary로 변환하는 메서드
    func toDictionary() -> [String: Any] {
        var result: [String: Any] = [:]
        result["date"] = date
        result["amount"] = amount
        result["job_count"] = jobCount
        return result
    }
}