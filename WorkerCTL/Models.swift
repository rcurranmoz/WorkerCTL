import Foundation

struct Worker: Identifiable, Codable {
    let workerGroup: String
    let workerId: String
    let firstClaim: String
    let lastDateActive: String
    let latestTask: LatestTask?
    let quarantineUntil: String?
    let recentErrors: Int?
    
    // Not from API - set after fetching task status
    var taskState: String?
    var recentFailures: Int = 0  // Count of recent failed tasks
    var hasRecentFailure: Bool { recentFailures > 0 }
    
    var id: String { workerId }
    
    var lastActive: Date? {
        ISO8601DateFormatter().date(from: lastDateActive)
    }
    
    var firstClaimDate: Date? {
        ISO8601DateFormatter().date(from: firstClaim)
    }
    
    var isQuarantined: Bool {
        guard let quarantineUntil = quarantineUntil else { return false }
        guard let date = ISO8601DateFormatter().date(from: quarantineUntil) else { return false }
        return date > Date()
    }
    
    var isActive: Bool {
        // If we have task state and it's running, definitely active
        if let taskState = taskState, taskState == "running" {
            return true
        }
        
        // Otherwise check last active time
        guard let lastActive = lastActive else { return false }
        let daysSinceActive = Date().timeIntervalSince(lastActive) / 86400
        return daysSinceActive < 7
    }
    
    var isRecentlyActive: Bool {
        // If task is running, it's recently active
        if let taskState = taskState, taskState == "running" {
            return true
        }
        
        guard let lastActive = lastActive else { return false }
        return Date().timeIntervalSince(lastActive) < 1800
    }
    
    enum CodingKeys: String, CodingKey {
        case workerGroup, workerId, firstClaim, lastDateActive
        case latestTask, quarantineUntil, recentErrors
    }
}

struct LatestTask: Codable {
    let runId: Int
    let taskId: String
}

struct WorkersResponse: Codable {
    let workers: [Worker]
    let continuationToken: String?
}

struct TaskStatus: Codable {
    let taskId: String
    let provisionerId: String
    let workerType: String
    let schedulerId: String
    let taskGroupId: String
    let deadline: String
    let expires: String
    let retriesLeft: Int
    let state: String
    let runs: [TaskRun]
}

struct TaskRun: Codable {
    let runId: Int
    let state: String
    let reasonCreated: String
    let reasonResolved: String?
    let workerGroup: String?
    let workerId: String?
    let takenUntil: String?
    let scheduled: String
    let started: String?
    let resolved: String?
}

struct TaskStatusResponse: Codable {
    let status: TaskStatus
}
