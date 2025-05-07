//
//  JobStatusUpdateViewModel.swift
//  HomeCleaningApp
//
//  Created by 황태욱 on 3/22/25.
//

import Foundation

class JobStatusUpdateViewModel {
    // MARK: - Properties
    
    private(set) var job: Job
    private let jobService = JobService.shared
    
    // Array of next status options
    var availableStatusOptions: [JobStatus] {
        switch job.status {
        case .assigned:
            return [.accepted, .cancelled]
        case .accepted:
            return [.onWay, .cancelled]
        case .onWay:
            return [.arrived, .cancelled]
        case .arrived:
            return [.inProgress, .cancelled]
        case .inProgress:
            return [.completed, .cancelled]
        case .completed, .cancelled:
            return []
        }
    }
    
    // Callbacks
    var jobDidUpdate: ((Job) -> Void)?
    var errorDidOccur: ((String) -> Void)?
    
    // MARK: - Initialization
    
    init(job: Job) {
        self.job = job
    }
    
    // MARK: - Methods
    
    // Update job status
    func updateStatus(to newStatus: JobStatus, completion: @escaping (Bool) -> Void) {
        guard availableStatusOptions.contains(newStatus) else {
            errorDidOccur?("Cannot change to '\(newStatus.displayName)' status for this job.")
            completion(false)
            return
        }
        
        jobService.updateJobStatus(
            jobId: job.id,
            status: newStatus,
            onSuccess: { [weak self] updatedJob in
                self?.job = updatedJob
                self?.jobDidUpdate?(updatedJob)
                completion(true)
            },
            onError: { [weak self] error in
                self?.errorDidOccur?(error.localizedDescription)
                completion(false)
            }
        )
    }
    
    // Add/update job notes
    func updateNotes(notes: String, completion: @escaping (Bool) -> Void) {
        jobService.updateJobNotes(
            jobId: job.id,
            notes: notes,
            onSuccess: { [weak self] updatedJob in
                self?.job = updatedJob
                self?.jobDidUpdate?(updatedJob)
                completion(true)
            },
            onError: { [weak self] error in
                self?.errorDidOccur?(error.localizedDescription)
                completion(false)
            }
        )
    }
    
    // Get display text for a specific status
    func getStatusActionText(for status: JobStatus) -> String {
        switch status {
        case .accepted:
            return "Accept Job"
        case .onWay:
            return "Start Moving to Location"
        case .arrived:
            return "Arrived at Location"
        case .inProgress:
            return "Start Job"
        case .completed:
            return "Complete Job"
        case .cancelled:
            return "Cancel Job"
        default:
            return "Update Status"
        }
    }
    
    // Get description for current status
    func getCurrentStatusDescription() -> String {
        switch job.status {
        case .assigned:
            return "New job has been assigned. Do you want to accept it?"
        case .accepted:
            return "You have accepted the job. Ready to start moving to the location?"
        case .onWay:
            return "You are on your way to the location. Press confirm when you arrive."
        case .arrived:
            return "You have arrived at the location. Ready to start the job?"
        case .inProgress:
            return "Job is in progress. Press confirm when completed."
        case .completed:
            return "Job has been completed."
        case .cancelled:
            return "Job has been cancelled."
        }
    }
}
