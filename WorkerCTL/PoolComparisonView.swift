import SwiftUI

struct PoolComparisonView: View {
    let pools: [WorkerPool]
    
    @StateObject private var api = TaskclusterAPI()
    @State private var pool1Workers: [Worker] = []
    @State private var pool2Workers: [Worker] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    private var analytics1: FleetAnalytics? {
        pool1Workers.isEmpty ? nil : FleetAnalytics(workers: pool1Workers)
    }
    
    private var analytics2: FleetAnalytics? {
        pool2Workers.isEmpty ? nil : FleetAnalytics(workers: pool2Workers)
    }
    
    var body: some View {
        NavigationView {
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
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        Text("Loading worker data...")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("This may take 20-30 seconds...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Data")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Try Again") {
                            Task {
                                await loadData()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let a1 = analytics1, let a2 = analytics2 {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header
                            comparisonHeader
                            
                            // Health Comparison
                            healthComparison(a1: a1, a2: a2)
                            
                            // Side by Side Stats
                            statComparison(a1: a1, a2: a2)
                            
                            // Activity Comparison
                            activityComparison(a1: a1, a2: a2)
                            
                            // Failure Comparison
                            failureComparison(a1: a1, a2: a2)
                            
                            // Winner Card
                            winnerCard(a1: a1, a2: a2)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Pool Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .task {
                await loadData()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var comparisonHeader: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(pools.indices.contains(0) ? pools[0].emoji : "🖥️")
                    .font(.system(size: 40))
                Text(pools.indices.contains(0) ? pools[0].displayName : "Unknown")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(pools.indices.contains(0) ? pools[0].workerType : "")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            
            Image(systemName: "arrow.left.arrow.right")
                .font(.title)
                .foregroundColor(.white.opacity(0.3))
            
            VStack(spacing: 4) {
                Text(pools.indices.contains(1) ? pools[1].emoji : "🖥️")
                    .font(.system(size: 40))
                Text(pools.indices.contains(1) ? pools[1].displayName : "Unknown")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(pools.indices.contains(1) ? pools[1].workerType : "")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
    
    private func healthComparison(a1: FleetAnalytics, a2: FleetAnalytics) -> some View {
        VStack(spacing: 16) {
            Text("Health Score")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(a1.healthScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(healthColor(a1.healthScore))
                    Text(a1.healthEmoji)
                        .font(.title)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text("\(a2.healthScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(healthColor(a2.healthScore))
                    Text(a2.healthEmoji)
                        .font(.title)
                }
                .frame(maxWidth: .infinity)
            }
            
            if a1.healthScore != a2.healthScore {
                let winner = a1.healthScore > a2.healthScore ? pools[0].displayName : pools[1].displayName
                let diff = abs(a1.healthScore - a2.healthScore)
                
                Text("\(winner) is healthier (+\(diff))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func statComparison(a1: FleetAnalytics, a2: FleetAnalytics) -> some View {
        VStack(spacing: 12) {
            Text("Key Metrics")
                .font(.headline)
                .foregroundColor(.white)
            
            ComparisonRow(
                metric: "Total Workers",
                value1: "\(pool1Workers.count)",
                value2: "\(pool2Workers.count)"
            )
            
            ComparisonRow(
                metric: "Active",
                value1: "\(pool1Workers.filter { $0.isActive }.count)",
                value2: "\(pool2Workers.filter { $0.isActive }.count)",
                higherBetter: true
            )
            
            ComparisonRow(
                metric: "Failures",
                value1: "\(a1.totalFailures)",
                value2: "\(a2.totalFailures)",
                higherBetter: false
            )
            
            ComparisonRow(
                metric: "Quarantined",
                value1: "\(pool1Workers.filter { $0.isQuarantined }.count)",
                value2: "\(pool2Workers.filter { $0.isQuarantined }.count)",
                higherBetter: false
            )
            
            ComparisonRow(
                metric: "Capacity",
                value1: "\(Int(a1.capacityUtilization * 100))%",
                value2: "\(Int(a2.capacityUtilization * 100))%",
                higherBetter: true
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func activityComparison(a1: FleetAnalytics, a2: FleetAnalytics) -> some View {
        let act1 = a1.activityBreakdown
        let act2 = a2.activityBreakdown
        
        return VStack(spacing: 12) {
            Text("Activity Breakdown")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(pools[0].displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 4) {
                        ActivityPill(label: "Active", count: act1.active, color: .green)
                        ActivityPill(label: "Recent", count: act1.recent, color: .blue)
                        ActivityPill(label: "Idle", count: act1.idle, color: .gray)
                    }
                }
                
                VStack(spacing: 8) {
                    Text(pools[1].displayName)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 4) {
                        ActivityPill(label: "Active", count: act2.active, color: .green)
                        ActivityPill(label: "Recent", count: act2.recent, color: .blue)
                        ActivityPill(label: "Idle", count: act2.idle, color: .gray)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func failureComparison(a1: FleetAnalytics, a2: FleetAnalytics) -> some View {
        VStack(spacing: 12) {
            Text("Failure Analysis")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("\(a1.totalFailures)")
                        .font(.title.bold())
                        .foregroundColor(.red)
                    Text("Total Failures")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text(pools[0].displayName)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 8) {
                    Text("\(a2.totalFailures)")
                        .font(.title.bold())
                        .foregroundColor(.red)
                    Text("Total Failures")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text(pools[1].displayName)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(String(format: "%.1f%%", a1.failureRate * 100))
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                    Text("Failure Rate")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 8) {
                    Text(String(format: "%.1f%%", a2.failureRate * 100))
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                    Text("Failure Rate")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func winnerCard(a1: FleetAnalytics, a2: FleetAnalytics) -> some View {
        let score1 = a1.healthScore
        let score2 = a2.healthScore
        
        let winner = score1 > score2 ? pools[0] : pools[1]
        let diff = abs(score1 - score2)
        
        return VStack(spacing: 12) {
            Text("🏆")
                .font(.system(size: 50))
            
            Text("Overall Winner")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            Text(winner.displayName)
                .font(.title.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            if diff > 5 {
                Text("Better by \(diff) health points")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            } else {
                Text("Very close competition!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
    
    private func healthColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .yellow
        case 40...59: return .orange
        default: return .red
        }
    }
    
    private func loadData() async {
        guard pools.count >= 2 else {
            await MainActor.run {
                errorMessage = "Need at least 2 pools to compare"
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Load pools sequentially to avoid overwhelming the API
            let workers1 = try await api.fetchWorkers(
                provisionerId: pools[0].provisionerId, 
                workerType: pools[0].workerType
            )
            
            let workers2 = try await api.fetchWorkers(
                provisionerId: pools[1].provisionerId, 
                workerType: pools[1].workerType
            )
            
            await MainActor.run {
                pool1Workers = workers1
                pool2Workers = workers2
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load worker data: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

struct ComparisonRow: View {
    let metric: String
    let value1: String
    let value2: String
    var higherBetter: Bool = false
    
    var body: some View {
        HStack {
            Text(value1)
                .font(.headline.monospacedDigit())
                .foregroundColor(betterColor(value1, value2, higherBetter))
                .frame(width: 60, alignment: .trailing)
            
            Text(metric)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
            
            Text(value2)
                .font(.headline.monospacedDigit())
                .foregroundColor(betterColor(value2, value1, higherBetter))
                .frame(width: 60, alignment: .leading)
        }
        .padding(.vertical, 4)
    }
    
    private func betterColor(_ val1: String, _ val2: String, _ higherBetter: Bool) -> Color {
        let num1 = Int(val1.filter { $0.isNumber }) ?? 0
        let num2 = Int(val2.filter { $0.isNumber }) ?? 0
        
        if num1 == num2 { return .white }
        
        let isBetter = higherBetter ? (num1 > num2) : (num1 < num2)
        return isBetter ? .green : .white.opacity(0.6)
    }
}

struct ActivityPill: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.caption.bold())
                .foregroundColor(color)
            
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
        }
    }
}
