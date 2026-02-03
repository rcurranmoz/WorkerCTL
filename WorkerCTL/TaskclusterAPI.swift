import Foundation
import Combine

class TaskclusterAPI: ObservableObject {
    // Replace with your Cloudflare Worker URL once deployed
    private let baseURL = "ios-worker-quarantine-5587.ryanpcurran-01e.workers.dev"
    
    // For direct API access (public endpoints don't need auth)
    private let taskclusterRootURL = "https://firefox-ci-tc.services.mozilla.com"
    
    @Published var isLoading = false
    @Published var error: String?
    
    /// Fetch workers for a specific pool
    func fetchWorkers(provisionerId: String, workerType: String, quarantined: Bool? = nil) async throws -> [Worker] {
        isLoading = true
        defer { isLoading = false }
        
        // Build URL with query parameters
        var components = URLComponents(string: "\(taskclusterRootURL)/api/queue/v1/provisioners/\(provisionerId)/worker-types/\(workerType)/workers")!
        
        var queryItems: [URLQueryItem] = []
        if let quarantined = quarantined {
            queryItems.append(URLQueryItem(name: "quarantined", value: String(quarantined)))
        }
        queryItems.append(URLQueryItem(name: "limit", value: "1000"))
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        print("Fetching: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let workersResponse = try JSONDecoder().decode(WorkersResponse.self, from: data)
        return workersResponse.workers
    }
    
    /// Fetch task status
    func fetchTaskStatus(taskId: String) async throws -> TaskStatus {
        let url = URL(string: "\(taskclusterRootURL)/api/queue/v1/task/\(taskId)/status")!
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let statusResponse = try JSONDecoder().decode(TaskStatusResponse.self, from: data)
        return statusResponse.status
    }
    
    // IMPORTANT: Set this to your Cloudflare Worker URL after deployment
    // Example: "https://workerctl-quarantine.your-subdomain.workers.dev"
    private let quarantineWorkerURL = "https://ios-worker-quarantine-5587.ryanpcurran-01e.workers.dev" // TODO: Replace with your worker URL
    
    /// Quarantine a worker for 30 days
    func quarantineWorker(provisionerId: String, workerType: String, workerGroup: String, workerId: String) async throws {
        guard !quarantineWorkerURL.isEmpty else {
            throw QuarantineError.workerURLNotConfigured
        }
        
        let url = URL(string: quarantineWorkerURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "action": "quarantine",
            "provisionerId": provisionerId,
            "workerType": workerType,
            "workerGroup": workerGroup,
            "workerId": workerId
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(QuarantineErrorResponse.self, from: data) {
                throw QuarantineError.apiError(errorResponse.error)
            }
            throw URLError(.badServerResponse)
        }
    }
    
    /// Remove quarantine from a worker
    func unquarantineWorker(provisionerId: String, workerType: String, workerGroup: String, workerId: String) async throws {
        guard !quarantineWorkerURL.isEmpty else {
            throw QuarantineError.workerURLNotConfigured
        }
        
        let url = URL(string: quarantineWorkerURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "action": "unquarantine",
            "provisionerId": provisionerId,
            "workerType": workerType,
            "workerGroup": workerGroup,
            "workerId": workerId
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(QuarantineErrorResponse.self, from: data) {
                throw QuarantineError.apiError(errorResponse.error)
            }
            throw URLError(.badServerResponse)
        }
    }
}

// MARK: - Quarantine Error Types
enum QuarantineError: LocalizedError {
    case workerURLNotConfigured
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .workerURLNotConfigured:
            return "Quarantine worker URL not configured. Please set quarantineWorkerURL in TaskclusterAPI.swift"
        case .apiError(let message):
            return "Quarantine failed: \(message)"
        }
    }
}

struct QuarantineErrorResponse: Codable {
    let error: String
}
