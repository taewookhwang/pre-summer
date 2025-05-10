//
//  JobViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class JobViewModel {
    // MARK: - Properties
    
    // Job list data
    private(set) var jobs: [Job] = []
    
    // Pagination
    private(set) var currentPage: Int = 1
    private(set) var totalPages: Int = 1
    private(set) var hasMorePages: Bool = false
    private(set) var isLoadingMoreJobs: Bool = false
    
    // UI State
    enum State {
        case idle
        case loading
        case loadingMore
        case loaded
        case error(String)
    }
    
    private(set) var state: State = .idle {
        didSet {
            stateDidChange?()
        }
    }
    
    // Callbacks
    var stateDidChange: (() -> Void)?
    var jobsDidLoad: (() -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // Service
    private let jobService = JobService.shared
    
    // MARK: - Methods
    
    // Load job list (first page)
    func loadJobs(showCompleted: Bool = false) {
        state = .loading
        currentPage = 1
        
        // For use with actual API calls
        jobService.getJobs(
            page: currentPage,
            limit: 10,
            showCompleted: showCompleted,
            onSuccess: { [weak self] jobs, pagination in
                guard let self = self else { return }
                
                self.updatePaginationInfo(pagination)
                self.handleJobsLoaded(jobs)
            },
            onError: { [weak self] error in
                self?.handleError(error)
            }
        )
        
        // Test dummy data - commented out in favor of real API
        // DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
        //     self?.handleJobsLoaded(self?.generateMockJobs(showCompleted: showCompleted) ?? [])
        // }
    }
    
    // Load more jobs (next page)
    func loadMoreJobs(showCompleted: Bool = false) {
        guard hasMorePages && !isLoadingMoreJobs else { return }
        
        isLoadingMoreJobs = true
        state = .loadingMore
        
        let nextPage = currentPage + 1
        
        jobService.getJobs(
            page: nextPage,
            limit: 10,
            showCompleted: showCompleted,
            onSuccess: { [weak self] jobs, pagination in
                guard let self = self else { return }
                
                self.currentPage = nextPage
                self.updatePaginationInfo(pagination)
                self.handleMoreJobsLoaded(jobs)
            },
            onError: { [weak self] error in
                self?.isLoadingMoreJobs = false
                self?.handleError(error)
            }
        )
    }
    
    // Update pagination information
    private func updatePaginationInfo(_ pagination: PaginationMeta?) {
        guard let pagination = pagination else { return }
        
        self.totalPages = pagination.pages
        self.hasMorePages = pagination.hasNextPage
    }
    
    // Update job status
    func updateJobStatus(job: Job, newStatus: JobStatus, completion: @escaping (Bool, String?) -> Void) {
        // For use with actual API calls
        // jobService.updateJobStatus(
        //     jobId: job.id,
        //     status: newStatus,
        //     onSuccess: { [weak self] updatedJob in
        //         // Update job list
        //         if let index = self?.jobs.firstIndex(where: { $0.id == updatedJob.id }) {
        //             self?.jobs[index] = updatedJob
        //             self?.jobsDidLoad?()
        //         }
        //         completion(true, nil)
        //     },
        //     onError: { error in
        //         completion(false, error.localizedDescription)
        //     }
        // )
        
        // Test dummy update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let index = self?.jobs.firstIndex(where: { $0.id == job.id }) {
                // Create a new Job instance with the updated status instead of modifying the existing one
                let updatedJob = Job(
                    id: job.id,
                    reservationId: job.reservationId,
                    technicianId: job.technicianId,
                    status: newStatus,
                    startTime: job.startTime,
                    endTime: job.endTime,
                    notes: job.notes,
                    createdAt: job.createdAt,
                    updatedAt: Date(),
                    reservation: job.reservation,
                    technician: job.technician
                )
                self?.jobs[index] = updatedJob
                self?.jobsDidLoad?()
                completion(true, nil)
            } else {
                completion(false, "Job not found")
            }
        }
    }
    
    // Get job details
    func getJobDetail(jobId: String, completion: @escaping (Job?, String?) -> Void) {
        // For use with actual API calls
        // jobService.getJobDetail(
        //     jobId: jobId,
        //     onSuccess: { job in
        //         completion(job, nil)
        //     },
        //     onError: { error in
        //         completion(nil, error.localizedDescription)
        //     }
        // )
        
        // Test dummy data
        if let job = jobs.first(where: { $0.id == jobId }) {
            completion(job, nil)
        } else {
            completion(nil, "Job not found")
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleJobsLoaded(_ jobs: [Job]) {
        self.jobs = jobs
        state = .loaded
        jobsDidLoad?()
    }
    
    private func handleMoreJobsLoaded(_ newJobs: [Job]) {
        self.jobs.append(contentsOf: newJobs)
        state = .loaded
        isLoadingMoreJobs = false
        jobsDidLoad?()
    }
    
    private func handleError(_ error: Error) {
        state = .error(error.localizedDescription)
        errorDidOccur?(error.localizedDescription)
    }
    
    // MARK: - Mock Data
    
    private func generateMockJobs(showCompleted: Bool) -> [Job] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Test dummy data
        let statuses: [JobStatus] = showCompleted ?
            [.completed, .cancelled] :
            [.assigned, .accepted, .onWay, .arrived, .inProgress]
        
        return (0..<5).map { index in
            let jobDate = calendar.date(byAdding: .hour, value: index * 2, to: currentDate)!
            let status = statuses[index % statuses.count]
            
            let serviceType = ["Apartment Cleaning", "Move-in Cleaning", "Furniture Cleaning", "Floor Cleaning", "Bathroom Cleaning"][index % 5]
            let address = ["Teheran-ro 123, Gangnam-gu, Seoul", "World Cup-ro 456, Mapo-gu, Seoul", "Itaewon-ro 789, Yongsan-gu, Seoul", "Yeouinaru-ro 101, Yeongdeungpo-gu, Seoul", "Olympic-ro 202, Songpa-gu, Seoul"][index % 5]
            
            // Test customer information
            let customer = AppUser(
                id: 10000 + index,
                email: "customer\(index)@example.com",
                role: "consumer",
                name: ["Customer Kim", "Consumer Lee", "User Park", "Requester Choi", "Client Jung"][index % 5],
                phone: "010-1234-567\(index)",
                address: address,
                createdAt: calendar.date(byAdding: .day, value: -30, to: currentDate)!
            )
            
            // Test service information
            let price = [50000.0, 100000.0, 70000.0, 80000.0, 60000.0][index % 5]
            let service = Service(
                id: "S\(20000 + index)",
                name: serviceType,
                description: "\(serviceType) service",
                price: String(Int(price)),
                duration: [2, 4, 3, 2, 1][index % 5],
                categoryId: "cat_cleaning",
                subcategoryId: nil,
                isActive: true,
                createdAt: calendar.date(byAdding: .day, value: -90, to: currentDate)!,
                updatedAt: calendar.date(byAdding: .day, value: -5, to: currentDate)!,
                imageURL: nil,
                thumbnail: nil,
                shortDescription: "Quick \(serviceType.lowercased())",
                basePrice: price,
                unit: "원",
                rating: [4.5, 4.8, 4.2, 4.7, 4.9][index % 5],
                reviewCount: [10, 25, 8, 15, 30][index % 5]
            )
            
            // Test reservation information
            let reservation = Reservation(
                legacyId: "R\(30000 + index)",
                userId: 10000 + index,
                serviceId: "S\(20000 + index)",
                technicianId: nil,
                reservationDate: jobDate,
                status: status == .cancelled ? .cancelled : .technicianAssigned,
                addressString: address,
                specialInstructions: "No special instructions",
                totalPrice: String([50000.0, 100000.0, 70000.0, 80000.0, 60000.0][index % 5]),
                paymentStatus: "completed",
                createdAt: calendar.date(byAdding: .day, value: -5, to: currentDate)!,
                updatedAt: calendar.date(byAdding: .day, value: -1, to: currentDate)!,
                service: service,
                technician: nil,
                payment: nil
            )
            
            // Test job information
            return Job(
                id: "J\(50000 + index)",
                reservationId: "R\(30000 + index)",
                technicianId: 1,
                status: status,
                startTime: status == .inProgress || status == .completed ? calendar.date(byAdding: .hour, value: -1, to: jobDate) : nil,
                endTime: status == .completed ? calendar.date(byAdding: .hour, value: 1, to: jobDate) : nil,
                notes: status == .completed ? "Work completed. Customer satisfied." : nil,
                createdAt: calendar.date(byAdding: .day, value: -5, to: currentDate)!,
                updatedAt: calendar.date(byAdding: .hour, value: -2, to: currentDate)!,
                reservation: reservation,
                technician: nil
            )
        }
    }
}