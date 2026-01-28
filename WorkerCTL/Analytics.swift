import Foundation

struct FleetAnalytics {
    let workers: [Worker]
    
    // MARK: - Health Score
    var healthScore: Int {
        guard !workers.isEmpty else { return 0 }
        
        let activeRatio = Double(workers.filter { $0.isActive }.count) / Double(workers.count)
        let failureRatio = Double(workers.filter { $0.hasRecentFailure }.count) / Double(workers.count)
        let quarantineRatio = Double(workers.filter { $0.isQuarantined }.count) / Double(workers.count)
        
        // Health = 100 - penalties
        let healthValue = 100.0 
            - (failureRatio * 30)      // Failures hurt most
            - (quarantineRatio * 25)    // Quarantines hurt
            - ((1.0 - activeRatio) * 20) // Inactivity hurts
        
        return max(0, min(100, Int(healthValue)))
    }
    
    var healthColor: String {
        switch healthScore {
        case 80...100: return "green"
        case 60...79: return "yellow"
        case 40...59: return "orange"
        default: return "red"
        }
    }
    
    var healthEmoji: String {
        switch healthScore {
        case 80...100: return "💚"
        case 60...79: return "💛"
        case 40...59: return "🧡"
        default: return "❤️"
        }
    }
    
    // MARK: - Worker Lifecycle
    var averageWorkerAge: TimeInterval {
        let ages = workers.compactMap { worker -> TimeInterval? in
            guard let firstClaim = worker.firstClaimDate else { return nil }
            return Date().timeIntervalSince(firstClaim)
        }
        
        guard !ages.isEmpty else { return 0 }
        return ages.reduce(0, +) / Double(ages.count)
    }
    
    var oldestWorker: Worker? {
        workers.min { w1, w2 in
            (w1.firstClaimDate ?? .distantFuture) < (w2.firstClaimDate ?? .distantFuture)
        }
    }
    
    var newestWorker: Worker? {
        workers.max { w1, w2 in
            (w1.firstClaimDate ?? .distantPast) < (w2.firstClaimDate ?? .distantPast)
        }
    }
    
    var staleWorkers: [Worker] {
        workers.filter { worker in
            guard let lastActive = worker.lastActive else { return false }
            let daysSince = Date().timeIntervalSince(lastActive) / 86400
            return daysSince > 30
        }
    }
    
    // MARK: - Failure Analytics
    var totalFailures: Int {
        workers.reduce(0) { $0 + $1.recentFailures }
    }
    
    var failureRate: Double {
        let workersWithTasks = workers.filter { $0.latestTask != nil }
        guard !workersWithTasks.isEmpty else { return 0 }
        
        let failed = workers.filter { $0.hasRecentFailure }
        return Double(failed.count) / Double(workersWithTasks.count)
    }
    
    var topFailingWorkers: [Worker] {
        workers
            .filter { $0.recentFailures > 0 }
            .sorted { $0.recentFailures > $1.recentFailures }
            .prefix(5)
            .map { $0 }
    }
    
    // MARK: - Activity Insights
    var activityBreakdown: (active: Int, recent: Int, idle: Int) {
        let active = workers.filter { worker in
            guard let lastActive = worker.lastActive else { return false }
            return Date().timeIntervalSince(lastActive) < 1800 // 30 min
        }.count
        
        let recent = workers.filter { worker in
            guard let lastActive = worker.lastActive else { return false }
            let interval = Date().timeIntervalSince(lastActive)
            return interval >= 1800 && interval < 86400 // 30min - 24h
        }.count
        
        let idle = workers.count - active - recent
        
        return (active, recent, idle)
    }
    
    // MARK: - Performance Insights
    var performanceSummary: String {
        let activity = activityBreakdown
        let activePercent = workers.isEmpty ? 0 : Int((Double(activity.active) / Double(workers.count)) * 100)
        
        if healthScore >= 80 {
            return "🎉 Excellent! \(activePercent)% actively working"
        } else if healthScore >= 60 {
            return "👍 Good. \(totalFailures) recent failures detected"
        } else if healthScore >= 40 {
            return "⚠️ Issues detected. \(workers.filter { $0.isQuarantined }.count) quarantined"
        } else {
            return "🚨 Critical. Immediate attention needed"
        }
    }
    
    // MARK: - Trends (simple heuristics without history)
    var estimatedTrend: String {
        // Look at recent vs old workers
        let recentWorkers = workers.filter { worker in
            guard let lastActive = worker.lastActive else { return false }
            return Date().timeIntervalSince(lastActive) < 3600
        }
        
        let recentFailureRate = recentWorkers.isEmpty ? 0 : 
            Double(recentWorkers.filter { $0.hasRecentFailure }.count) / Double(recentWorkers.count)
        
        if recentFailureRate > failureRate * 1.2 {
            return "↘️ Degrading"
        } else if recentFailureRate < failureRate * 0.8 {
            return "↗️ Improving"
        }
        return "→ Stable"
    }
    
    // MARK: - Anomaly Detection
    var anomalies: [String] {
        var issues: [String] = []
        
        // Unusual quarantine rate
        let quarantineRate = Double(workers.filter { $0.isQuarantined }.count) / Double(max(1, workers.count))
        if quarantineRate > 0.1 {
            issues.append("⚠️ High quarantine rate: \(Int(quarantineRate * 100))%")
        }
        
        // Unusual failure concentration
        if let topFailer = topFailingWorkers.first, topFailer.recentFailures >= 4 {
            issues.append("🔥 \(topFailer.workerId) has \(topFailer.recentFailures) failures")
        }
        
        // Too many idle workers
        let activity = activityBreakdown
        let idlePercent = Double(activity.idle) / Double(max(1, workers.count))
        if idlePercent > 0.5 {
            issues.append("😴 \(Int(idlePercent * 100))% workers idle")
        }
        
        // All workers inactive
        if activity.active == 0 && workers.count > 0 {
            issues.append("🚨 No active workers!")
        }
        
        return issues
    }
    
    // MARK: - Capacity Insights
    var capacityUtilization: Double {
        let activity = activityBreakdown
        return Double(activity.active) / Double(max(1, workers.count))
    }
    
    var utilizationEmoji: String {
        let util = capacityUtilization
        if util > 0.8 { return "🔥" }
        if util > 0.5 { return "💪" }
        if util > 0.2 { return "😌" }
        return "💤"
    }
}

// MARK: - Pool Comparison
struct PoolComparison {
    let pool1: (name: String, analytics: FleetAnalytics)
    let pool2: (name: String, analytics: FleetAnalytics)
    
    var healthDifference: Int {
        pool1.analytics.healthScore - pool2.analytics.healthScore
    }
    
    var betterPool: String {
        healthDifference > 0 ? pool1.name : pool2.name
    }
    
    var comparison: String {
        let diff = abs(healthDifference)
        if diff > 20 {
            return "\(betterPool) significantly better (+\(diff) health)"
        } else if diff > 5 {
            return "\(betterPool) slightly better (+\(diff) health)"
        }
        return "Similar performance"
    }
}
