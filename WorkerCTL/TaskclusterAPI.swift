import Foundation
import Combine

class TaskclusterAPI: ObservableObject {
    // Replace with your Cloudflare Worker URL once deployed
    private let baseURL = "https://your-worker.workers.dev"
    
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
    
    /// Quarantine a worker (requires authentication)
    func quarantineWorker(provisionerId: String, workerType: String, workerId: String, quarantineUntil: Date) async throws {
        // This would use the Cloudflare Worker for authenticated requests
        let url = URL(string: "\(baseURL)/workers/\(provisionerId)/\(workerType)/\(workerId)/quarantine")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = ISO8601DateFormatter()
        let body: [String: Any] = [
            "quarantineUntil": formatter.string(from: quarantineUntil)
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
}
