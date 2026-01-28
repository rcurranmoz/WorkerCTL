import SwiftUI

struct WorkerListView: View {
    let provisionerId: String
    let workerType: String
    
    @StateObject private var api = TaskclusterAPI()
    @State private var workers: [Worker] = []
    @State private var filteredWorkers: [Worker] = []
    @State private var searchText = ""
    @State private var filterQuarantined: FilterOption = .all
    @State private var filterActive: FilterOption = .all
    @State private var filterFailures: FilterOption = .all
    @State private var sortOrder: SortOrder = .lastActive
    @State private var selectedWorker: Worker?
    @State private var showingWorkerDetail = false
    @State private var fetchingTaskStates = false
    @State private var taskStateProgress: Double = 0
    
    enum FilterOption {
        case all, yes, no
    }
    
    enum SortOrder {
        case lastActive, workerId, firstClaim
    }
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.15, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Stats bar
                statsBar
                
                // Filters
                filterBar
                
                // Worker list
                if api.isLoading && workers.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Loading workers...")
                            .foregroundColor(.white)
                            .tint(.blue)
                        Spacer()
                    }
                } else if filteredWorkers.isEmpty {
                    emptyState
                } else {
                    workerList
                }
            }
        }
        .navigationTitle("\(workerType)")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await loadWorkers()
        }
        .task {
            await loadWorkers()
        }
        .sheet(item: $selectedWorker) { worker in
            WorkerDetailView(worker: worker, provisionerId: provisionerId, workerType: workerType)
        }
        .preferredColorScheme(.dark)
    }
    
    private var statsBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 20) {
                StatItem(label: "Total", value: "\(workers.count)", gradient: [.blue, .cyan])
                StatItem(label: "Active", value: "\(workers.filter { $0.isActive }.count)", gradient: [.green, .mint])
                StatItem(label: "Failures", value: "\(workers.filter { $0.hasRecentFailure }.count)", gradient: [.red, .pink])
                StatItem(label: "Quarantined", value: "\(workers.filter { $0.isQuarantined }.count)", gradient: [.orange, .red])
            }
            
            // Progress indicator while fetching task states
            if fetchingTaskStates {
                VStack(spacing: 4) {
                    ProgressView(value: taskStateProgress) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text("Checking task status...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .progressViewStyle(.linear)
                    .tint(.blue)
                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.2).opacity(0.8),
                    Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.7))
                    TextField("Search workers", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                        .frame(width: 150)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                // Sort
                Menu {
                    Button("Last Active") { sortOrder = .lastActive }
                    Button("Worker ID") { sortOrder = .workerId }
                    Button("First Claim") { sortOrder = .firstClaim }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Filter quarantined
                Menu {
                    Button("All") { filterQuarantined = .all }
                    Button("Quarantined") { filterQuarantined = .yes }
                    Button("Not Quarantined") { filterQuarantined = .no }
                } label: {
                    Label("Quarantine", systemImage: filterQuarantined == .yes ? "exclamationmark.triangle.fill" : "exclamationmark.triangle")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(filterQuarantined != .all ? LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                }
                
                // Filter active
                Menu {
                    Button("All") { filterActive = .all }
                    Button("Active") { filterActive = .yes }
                    Button("Inactive") { filterActive = .no }
                } label: {
                    Label("Activity", systemImage: filterActive == .yes ? "bolt.fill" : "bolt")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(filterActive != .all ? LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                }
                
                // Filter failures
                Menu {
                    Button("All") { filterFailures = .all }
                    Button("With Failures") { filterFailures = .yes }
                    Button("No Failures") { filterFailures = .no }
                } label: {
                    Label("Failures", systemImage: filterFailures == .yes ? "xmark.circle.fill" : "xmark.circle")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(filterFailures != .all ? LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.5))
        .onChange(of: searchText) { applyFilters() }
        .onChange(of: filterQuarantined) { applyFilters() }
        .onChange(of: filterActive) { applyFilters() }
        .onChange(of: filterFailures) { applyFilters() }
        .onChange(of: sortOrder) { applyFilters() }
    }
    
    private var workerList: some View {
        List {
            ForEach(filteredWorkers) { worker in
                WorkerRow(worker: worker)
                    .listRowBackground(Color.white.opacity(0.05))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedWorker = worker
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("No workers found")
                .font(.headline)
                .foregroundColor(.white)
            Text("Try adjusting your filters")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadWorkers() async {
        do {
            workers = try await api.fetchWorkers(provisionerId: provisionerId, workerType: workerType)
            applyFilters()
            
            // Background task: fetch task states for all workers with tasks
            Task {
                await fetchTaskStates()
            }
        } catch {
            print("Error loading workers: \(error)")
        }
    }
    
    private func fetchTaskStates() async {
        let workersWithTasks = workers.enumerated().filter { $0.element.latestTask != nil }
        
        guard !workersWithTasks.isEmpty else { return }
        
        await MainActor.run {
            fetchingTaskStates = true
            taskStateProgress = 0
        }
        
        let total = Double(workersWithTasks.count)
        var completed = 0.0
        
        // Process in concurrent batches of 10 for speed
        await withTaskGroup(of: (Int, String?, Int).self) { group in
            for (index, worker) in workersWithTasks {
                guard let latestTask = worker.latestTask else { continue }
                
                group.addTask {
                    do {
                        let status = try await self.api.fetchTaskStatus(taskId: latestTask.taskId)
                        
                        // Count recent failures (last 5 runs)
                        let recentRuns = status.runs.suffix(5)
                        let failureCount = recentRuns.filter { 
                            $0.state == "failed" || $0.state == "exception" 
                        }.count
                        
                        return (index, status.state, failureCount)
                    } catch {
                        return (index, nil, 0)
                    }
                }
            }
            
            for await (index, taskState, failureCount) in group {
                await MainActor.run {
                    if let taskState = taskState {
                        workers[index].taskState = taskState
                    }
                    workers[index].recentFailures = failureCount
                    
                    completed += 1
                    taskStateProgress = completed / total
                    
                    // Update UI every 10 workers or at end
                    if Int(completed) % 10 == 0 || completed == total {
                        applyFilters()
                    }
                }
            }
        }
        
        await MainActor.run {
            fetchingTaskStates = false
            applyFilters()
        }
    }
    
    private func applyFilters() {
        var result = workers
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { worker in
                worker.workerId.localizedCaseInsensitiveContains(searchText) ||
                worker.workerGroup.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Quarantine filter
        switch filterQuarantined {
        case .yes:
            result = result.filter { $0.isQuarantined }
        case .no:
            result = result.filter { !$0.isQuarantined }
        case .all:
            break
        }
        
        // Active filter
        switch filterActive {
        case .yes:
            result = result.filter { $0.isActive }
        case .no:
            result = result.filter { !$0.isActive }
        case .all:
            break
        }
        
        // Failures filter
        switch filterFailures {
        case .yes:
            result = result.filter { $0.hasRecentFailure }
        case .no:
            result = result.filter { !$0.hasRecentFailure }
        case .all:
            break
        }
        
        // Sort
        switch sortOrder {
        case .lastActive:
            result.sort { ($0.lastActive ?? .distantPast) > ($1.lastActive ?? .distantPast) }
        case .workerId:
            result.sort { $0.workerId < $1.workerId }
        case .firstClaim:
            result.sort { ($0.firstClaimDate ?? .distantPast) > ($1.firstClaimDate ?? .distantPast) }
        }
        
        filteredWorkers = result
    }
}

struct WorkerRow: View {
    let worker: Worker
    
    private var statusColor: Color {
        // If we know the task state, use that
        if let taskState = worker.taskState {
            if taskState == "running" { return .green }
            if taskState == "pending" { return .mint }
            if taskState == "completed" { return .blue }
            if taskState == "failed" { return .red }
        }
        
        // Otherwise fall back to lastDateActive
        guard let lastActive = worker.lastActive else { return .gray }
        let minutesSince = Date().timeIntervalSince(lastActive) / 60
        
        if minutesSince < 30 { return .green }      // Last 30 min
        if minutesSince < 120 { return .mint }      // Last 2 hours  
        if minutesSince < 1440 { return .blue }     // Last 24 hours
        if minutesSince < 10080 { return .orange }  // Last 7 days
        return .red                                  // Over 7 days
    }
    
    private var statusLabel: String {
        // If we know the task state, show that
        if let taskState = worker.taskState {
            return taskState.capitalized
        }
        
        // Otherwise show time-based status
        guard let lastActive = worker.lastActive else { return "Unknown" }
        let minutesSince = Date().timeIntervalSince(lastActive) / 60
        
        if minutesSince < 30 { return "Active" }
        if minutesSince < 120 { return "Recent" }
        if minutesSince < 1440 { return "Today" }
        if minutesSince < 10080 { return "This Week" }
        return "Idle"
    }
    
    private var detailedTime: String {
        // Don't show time if we have task state (it's confusing)
        if worker.taskState != nil {
            return ""
        }
        
        guard let lastActive = worker.lastActive else { return "" }
        let interval = Date().timeIntervalSince(lastActive)
        
        if interval < 60 {
            return "\(Int(interval))s ago"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(worker.workerId)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Failure badge
                if worker.hasRecentFailure {
                    HStack(spacing: 2) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption2)
                        Text("\(worker.recentFailures)")
                            .font(.caption2.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.red, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                
                Spacer()
                
                if worker.isQuarantined {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Status indicator with label
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: statusColor, radius: 2)
                    
                    Text(statusLabel)
                        .font(.caption2.bold())
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.15))
                .cornerRadius(8)
            }
            
            HStack {
                Label(worker.workerGroup, systemImage: "building.2")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                // Show detailed time
                Text(detailedTime)
                    .font(.caption.monospacedDigit())
                    .foregroundColor(statusColor.opacity(0.8))
            }
            
            if let latestTask = worker.latestTask {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                    Text(latestTask.taskId.prefix(8) + "...")
                        .font(.caption.monospaced())
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    var gradient: [Color] = [.blue, .purple]
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

extension Date {
    func timeAgo() -> String {
        let interval = Date().timeIntervalSince(self)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}
