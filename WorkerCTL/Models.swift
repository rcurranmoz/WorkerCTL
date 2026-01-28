import Foundation

struct Worker: Identifiable, Codable {
    let workerGroup: String
    let workerId: String
    let firstClaim: String
    let lastDateActive: String
    let latestTask: LatestTask?
    let quarantineUntil: String?
    let recentErrors: Int?
    
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
        guard let lastActive = lastActive else { return false }
        // Consider active if seen in last 24 hours (workers in busy pools may take time between tasks)
        return Date().timeIntervalSince(lastActive) < 86400
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
