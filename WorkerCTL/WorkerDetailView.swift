import SwiftUI

struct WorkerDetailView: View {
    let worker: Worker
    let provisionerId: String
    let workerType: String
    
    @StateObject private var api = TaskclusterAPI()
    @State private var taskStatus: TaskStatus?
    @State private var showingQuarantineAlert = false
    @State private var isQuarantining = false
    @State private var quarantineError: String?
    @State private var quarantineSuccess = false
    @State private var lastAction: String? // Track what action we just did
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Worker Info
                Section("Worker Information") {
                    DetailInfoRow(label: "Worker ID", value: worker.workerId, monospaced: true)
                    DetailInfoRow(label: "Worker Group", value: worker.workerGroup)
                    
                    if let lastActive = worker.lastActive {
                        DetailInfoRow(label: "Last Active", value: lastActive.formatted(date: .abbreviated, time: .shortened))
                        DetailInfoRow(label: "Active", value: lastActive.timeAgo())
                    }
                    
                    if let firstClaim = worker.firstClaimDate {
                        DetailInfoRow(label: "First Claim", value: firstClaim.formatted(date: .abbreviated, time: .shortened))
                    }
                    
                    HStack {
                        Text("Status")
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(worker.isActive ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)
                            Text(worker.isActive ? "Active" : "Inactive")
                                .font(.body.monospacedDigit())
                        }
                    }
                    
                    if worker.isQuarantined {
                        HStack {
                            Text("Quarantined")
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Latest Task
                if let latestTask = worker.latestTask {
                    Section("Latest Task") {
                        DetailInfoRow(label: "Task ID", value: latestTask.taskId, monospaced: true)
                        DetailInfoRow(label: "Run ID", value: String(latestTask.runId))
                        
                        if let status = taskStatus {
                            DetailInfoRow(label: "State", value: status.state)
                            
                            if let lastRun = status.runs.last {
                                if let started = lastRun.started, let startedDate = ISO8601DateFormatter().date(from: started) {
                                    DetailInfoRow(label: "Started", value: startedDate.formatted(date: .abbreviated, time: .shortened))
                                }
                                
                                if let resolved = lastRun.resolved, let resolvedDate = ISO8601DateFormatter().date(from: resolved) {
                                    DetailInfoRow(label: "Resolved", value: resolvedDate.formatted(date: .abbreviated, time: .shortened))
                                }
                                
                                DetailInfoRow(label: "Run State", value: lastRun.state)
                            }
                            
                            Button {
                                openTaskInBrowser()
                            } label: {
                                Label("View in Taskcluster", systemImage: "arrow.up.right.square")
                            }
                        } else if api.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                }
                
                // Actions
                Section("Actions") {
                    Button {
                        openWorkerInBrowser()
                    } label: {
                        Label("View in Taskcluster", systemImage: "arrow.up.right.square")
                    }
                    
                    // Quarantine toggle
                    if worker.isQuarantined {
                        Button(role: .destructive) {
                            Task {
                                await unquarantineWorker()
                            }
                        } label: {
                            if isQuarantining {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Removing Quarantine...")
                                }
                            } else {
                                Label("Remove Quarantine", systemImage: "checkmark.circle")
                            }
                        }
                        .disabled(isQuarantining)
                    } else {
                        Button(role: .destructive) {
                            Task {
                                await quarantineWorker()
                            }
                        } label: {
                            if isQuarantining {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Quarantining...")
                                }
                            } else {
                                Label("Quarantine Worker (30 days)", systemImage: "exclamationmark.triangle.fill")
                            }
                        }
                        .disabled(isQuarantining)
                    }
                }
                
                // Success/Error messages
                if quarantineSuccess {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(lastAction == "quarantine" ? "Worker quarantined successfully" : "Quarantine removed successfully")
                                .foregroundColor(.green)
                        }
                    }
                }
                
                if let error = quarantineError {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Worker Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadTaskStatus()
            }
        }
    }
    
    private func loadTaskStatus() async {
        guard let latestTask = worker.latestTask else { return }
        
        do {
            taskStatus = try await api.fetchTaskStatus(taskId: latestTask.taskId)
        } catch {
            print("Error loading task status: \(error)")
        }
    }
    
    private func quarantineWorker() async {
        isQuarantining = true
        quarantineError = nil
        quarantineSuccess = false
        lastAction = "quarantine"
        
        do {
            try await api.quarantineWorker(
                provisionerId: provisionerId,
                workerType: workerType,
                workerGroup: worker.workerGroup,
                workerId: worker.workerId
            )
            
            await MainActor.run {
                quarantineSuccess = true
                isQuarantining = false
            }
            
            // Auto-dismiss after 2 seconds
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                quarantineError = error.localizedDescription
                isQuarantining = false
            }
        }
    }
    
    private func unquarantineWorker() async {
        isQuarantining = true
        quarantineError = nil
        quarantineSuccess = false
        lastAction = "unquarantine"
        
        do {
            try await api.unquarantineWorker(
                provisionerId: provisionerId,
                workerType: workerType,
                workerGroup: worker.workerGroup,
                workerId: worker.workerId
            )
            
            await MainActor.run {
                quarantineSuccess = true
                isQuarantining = false
            }
            
            // Auto-dismiss after 2 seconds
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                quarantineError = error.localizedDescription
                isQuarantining = false
            }
        }
    }
    
    private func openWorkerInBrowser() {
        let urlString = "https://firefox-ci-tc.services.mozilla.com/provisioners/\(provisionerId)/worker-types/\(workerType)/workers/\(worker.workerGroup)/\(worker.workerId)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTaskInBrowser() {
        guard let latestTask = worker.latestTask else { return }
        let urlString = "https://firefox-ci-tc.services.mozilla.com/tasks/\(latestTask.taskId)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct DetailInfoRow: View {
    let label: String
    let value: String
    var monospaced: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(monospaced ? .body.monospaced() : .body)
                .textSelection(.enabled)
        }
    }
}
