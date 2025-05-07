//
//  JobService.swift
//  HomeCleaningApp
//
//  Created by Developer on 3/22/25.
//

import Foundation

class JobService {
    static let shared = JobService()
    
    private init() {}
    
    // JobAPI 의존성
    private let jobAPI = JobAPI.shared
    
    // 작업 목록 조회
    func getJobs(showCompleted: Bool = false, onSuccess: @escaping ([Job]) -> Void, onError: @escaping (Error) -> Void) {
        jobAPI.getJobs(showCompleted: showCompleted) { result in
            switch result {
            case .success(let jobs):
                onSuccess(jobs)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    // 작업 상세 정보 조회
    func getJobDetail(jobId: String, onSuccess: @escaping (Job) -> Void, onError: @escaping (Error) -> Void) {
        jobAPI.getJobDetail(jobId: jobId) { result in
            switch result {
            case .success(let job):
                onSuccess(job)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    // 작업 상태 업데이트
    func updateJobStatus(jobId: String, status: JobStatus, onSuccess: @escaping (Job) -> Void, onError: @escaping (Error) -> Void) {
        jobAPI.updateJobStatus(jobId: jobId, status: status) { result in
            switch result {
            case .success(let job):
                onSuccess(job)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    // 작업 메모 업데이트
    func updateJobNotes(jobId: String, notes: String, onSuccess: @escaping (Job) -> Void, onError: @escaping (Error) -> Void) {
        jobAPI.updateJobNotes(jobId: jobId, notes: notes) { result in
            switch result {
            case .success(let job):
                onSuccess(job)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    // 작업 사진 업로드
    func uploadJobPhotos(jobId: String, images: [Data], onSuccess: @escaping (Job) -> Void, onError: @escaping (Error) -> Void) {
        jobAPI.uploadJobPhotos(jobId: jobId, images: images) { result in
            switch result {
            case .success(let job):
                onSuccess(job)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    // 기술자 일정 조회
    func getTechnicianSchedule(date: Date, onSuccess: @escaping ([Job]) -> Void, onError: @escaping (Error) -> Void) {
        jobAPI.getTechnicianSchedule(date: date) { result in
            switch result {
            case .success(let jobs):
                onSuccess(jobs)
            case .failure(let error):
                onError(error)
            }
        }
    }
    
    // 기술자 수입 데이터 조회
    func getTechnicianEarnings(startDate: Date, endDate: Date, onSuccess: @escaping ([String: Any]) -> Void, onError: @escaping (Error) -> Void) {
        jobAPI.getTechnicianEarnings(startDate: startDate, endDate: endDate) { result in
            switch result {
            case .success(let earnings):
                onSuccess(earnings)
            case .failure(let error):
                onError(error)
            }
        }
    }
}