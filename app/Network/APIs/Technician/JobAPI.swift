import Foundation

enum JobAPIError: Error {
    case decodingFailed(Error)
    case invalidResponse
}

class JobAPI {
    static let shared = JobAPI()
    
    private init() {}
    
    private let apiGateway = APIGateway.shared
    
    // Get job list
    func getJobs(showCompleted: Bool = false, completion: @escaping (Result<[Job], Error>) -> Void) {
        let endpoint = "/technician/jobs"
        var queryParams: [String: Any] = [:]
        
        if showCompleted {
            queryParams["status"] = "completed,cancelled"
        } else {
            queryParams["status"] = "assigned,accepted,on_way,arrived,in_progress"
        }
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: queryParams,
            headers: ["Authorization": "Bearer \(getAuthToken())"]
        ) { (result: Result<JobListResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.jobs))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get job detail
    func getJobDetail(jobId: String, completion: @escaping (Result<Job, Error>) -> Void) {
        let endpoint = "/technician/jobs/\(jobId)"
        
        apiGateway.request(
            endpoint,
            method: .get,
            headers: ["Authorization": "Bearer \(getAuthToken())"]
        ) { (result: Result<JobDetailResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.job))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Update job status
    func updateJobStatus(jobId: String, status: JobStatus, completion: @escaping (Result<Job, Error>) -> Void) {
        let endpoint = "/technician/jobs/\(jobId)/status"
        let parameters: [String: Any] = ["status": status.rawValue]
        
        apiGateway.request(
            endpoint,
            method: .put,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"]
        ) { (result: Result<JobUpdateResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.job))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Update job notes
    func updateJobNotes(jobId: String, notes: String, completion: @escaping (Result<Job, Error>) -> Void) {
        let endpoint = "/technician/jobs/\(jobId)/notes"
        let parameters: [String: Any] = ["notes": notes]
        
        apiGateway.request(
            endpoint,
            method: .put,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"]
        ) { (result: Result<JobUpdateResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.job))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Upload job photos - 현재 APIGateway에 uploadMultipartData 메서드가 없으므로 기본 request로 대체
    func uploadJobPhotos(jobId: String, images: [Data], completion: @escaping (Result<Job, Error>) -> Void) {
        let endpoint = "/technician/jobs/\(jobId)/photos"
        
        // 멀티파트 업로드 기능이 없으므로 임시 구현
        // 실제 구현에서는 멀티파트 업로드 메서드 구현 필요
        let parameters: [String: Any] = ["photo_count": images.count]
        
        apiGateway.request(
            endpoint,
            method: .post,
            parameters: parameters,
            headers: ["Authorization": "Bearer \(getAuthToken())"]
        ) { (result: Result<JobUpdateResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.job))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get technician schedule
    func getTechnicianSchedule(date: Date, completion: @escaping (Result<[Job], Error>) -> Void) {
        let endpoint = "/technician/schedule"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        let queryParams: [String: Any] = ["date": dateString]
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: queryParams,
            headers: ["Authorization": "Bearer \(getAuthToken())"]
        ) { (result: Result<ScheduleResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.jobs))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Get technician earnings
    func getTechnicianEarnings(startDate: Date, endDate: Date, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let endpoint = "/technician/earnings"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        let queryParams: [String: Any] = [
            "start_date": startDateString,
            "end_date": endDateString
        ]
        
        apiGateway.request(
            endpoint,
            method: .get,
            parameters: queryParams,
            headers: ["Authorization": "Bearer \(getAuthToken())"]
        ) { (result: Result<EarningsResponse, APIError>) in
            switch result {
            case .success(let response):
                // EarningsData 객체를 Dictionary로 변환
                let earningsDictionary = response.data.toDictionary()
                completion(.success(earningsDictionary))
            
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Helper to get auth token
    private func getAuthToken() -> String {
        return UserDefaults.standard.string(forKey: "accessToken") ?? ""
    }
}

// Response models
struct JobListResponse: Decodable {
    let success: Bool
    let jobs: [Job]
}

struct JobDetailResponse: Decodable {
    let success: Bool
    let job: Job
}

struct JobUpdateResponse: Decodable {
    let success: Bool
    let job: Job
}

struct ScheduleResponse: Decodable {
    let success: Bool
    let jobs: [Job]
}

// API 응답 모델
struct EarningsResponse: Decodable {
    let success: Bool
    let data: EarningsData
}