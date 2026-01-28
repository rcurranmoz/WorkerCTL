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
    @State private var sortOrder: SortOrder = .lastActive
    @State private var selectedWorker: Worker?
    @State private var showingWorkerDetail = false
    
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
        HStack(spacing: 20) {
            StatItem(label: "Total", value: "\(workers.count)", gradient: [.blue, .cyan])
            StatItem(label: "Active", value: "\(workers.filter { $0.isActive }.count)", gradient: [.green, .mint])
            StatItem(label: "Quarantined", value: "\(workers.filter { $0.isQuarantined }.count)", gradient: [.orange, .red])
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
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).opacity(0.5))
        .onChange(of: searchText) { applyFilters() }
        .onChange(of: filterQuarantined) { applyFilters() }
        .onChange(of: filterActive) { applyFilters() }
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
        } catch {
            print("Error loading workers: \(error)")
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(worker.workerId)
                    .font(.headline)
                    .foregroundColor(.white)
                
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
                
                if worker.isActive {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 10, height: 10)
                        .shadow(color: .green, radius: 3)
                }
            }
            
            HStack {
                Label(worker.workerGroup, systemImage: "building.2")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                if let lastActive = worker.lastActive {
                    Text(lastActive.timeAgo())
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.8))
                }
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
