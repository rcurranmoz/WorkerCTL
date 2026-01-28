import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    let provisionerId: String
    let workerType: String
    let workers: [Worker]
    
    @Environment(\.dismiss) private var dismiss
    
    private var analytics: FleetAnalytics {
        FleetAnalytics(workers: workers)
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Health Score Hero
                        healthScoreCard
                        
                        // Quick Stats
                        quickStatsGrid
                        
                        // Activity Breakdown Chart
                        activityChart
                        
                        // Anomalies
                        if !analytics.anomalies.isEmpty {
                            anomaliesCard
                        }
                        
                        // Top Failing Workers
                        if !analytics.topFailingWorkers.isEmpty {
                            topFailersCard
                        }
                        
                        // Worker Lifecycle
                        lifecycleCard
                        
                        // Detailed Metrics
                        detailedMetricsCard
                    }
                    .padding()
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Health Score Card
    private var healthScoreCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(analytics.healthEmoji)
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fleet Health")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 8) {
                        Text("\(analytics.healthScore)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: healthGradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(analytics.estimatedTrend)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            
            Text(analytics.performanceSummary)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Health bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: healthGradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (Double(analytics.healthScore) / 100.0))
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: healthGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
    
    private var healthGradient: [Color] {
        switch analytics.healthScore {
        case 80...100: return [.green, .mint]
        case 60...79: return [.yellow, .orange]
        case 40...59: return [.orange, .red]
        default: return [.red, .pink]
        }
    }
    
    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
            StatCard(
                icon: "bolt.fill",
                label: "Capacity",
                value: "\(Int(analytics.capacityUtilization * 100))%",
                emoji: analytics.utilizationEmoji,
                gradient: [.blue, .cyan]
            )
            
            StatCard(
                icon: "exclamationmark.triangle.fill",
                label: "Failures",
                value: "\(analytics.totalFailures)",
                emoji: analytics.totalFailures > 10 ? "🔥" : "✓",
                gradient: [.red, .pink]
            )
            
            StatCard(
                icon: "clock.fill",
                label: "Avg Age",
                value: formatAge(analytics.averageWorkerAge),
                emoji: "⏱️",
                gradient: [.purple, .pink]
            )
            
            StatCard(
                icon: "bed.double.fill",
                label: "Stale Workers",
                value: "\(analytics.staleWorkers.count)",
                emoji: analytics.staleWorkers.isEmpty ? "✓" : "⚠️",
                gradient: [.orange, .yellow]
            )
        }
    }
    
    // MARK: - Activity Chart
    private var activityChart: some View {
        let activity = analytics.activityBreakdown
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Activity Breakdown")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                ActivityBar(
                    label: "Active",
                    count: activity.active,
                    total: workers.count,
                    color: .green
                )
                
                ActivityBar(
                    label: "Recent",
                    count: activity.recent,
                    total: workers.count,
                    color: .blue
                )
                
                ActivityBar(
                    label: "Idle",
                    count: activity.idle,
                    total: workers.count,
                    color: .gray
                )
            }
            
            // Legend
            HStack(spacing: 16) {
                LegendItem(color: .green, label: "Active (< 30m)")
                LegendItem(color: .blue, label: "Recent (< 24h)")
                LegendItem(color: .gray, label: "Idle (> 24h)")
            }
            .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Anomalies Card
    private var anomaliesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Anomalies Detected", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundColor(.orange)
            
            ForEach(analytics.anomalies, id: \.self) { anomaly in
                HStack {
                    Text(anomaly)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.5), lineWidth: 1)
        )
    }
    
    // MARK: - Top Failers Card
    private var topFailersCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Top Failing Workers", systemImage: "flame.fill")
                .font(.headline)
                .foregroundColor(.red)
            
            ForEach(analytics.topFailingWorkers) { worker in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(worker.workerId)
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                        
                        Text(worker.workerGroup)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("\(worker.recentFailures)")
                            .font(.headline.bold())
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Lifecycle Card
    private var lifecycleCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Worker Lifecycle", systemImage: "clock.arrow.circlepath")
                .font(.headline)
                .foregroundColor(.white)
            
            if let oldest = analytics.oldestWorker, let oldestDate = oldest.firstClaimDate {
                LifecycleRow(
                    icon: "tortoise.fill",
                    label: "Oldest",
                    worker: oldest.workerId,
                    age: Date().timeIntervalSince(oldestDate)
                )
            }
            
            if let newest = analytics.newestWorker, let newestDate = newest.firstClaimDate {
                LifecycleRow(
                    icon: "hare.fill",
                    label: "Newest",
                    worker: newest.workerId,
                    age: Date().timeIntervalSince(newestDate)
                )
            }
            
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.cyan)
                Text("Average Age:")
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(formatAge(analytics.averageWorkerAge))
                    .font(.headline)
                    .foregroundColor(.cyan)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Detailed Metrics
    private var detailedMetricsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detailed Metrics")
                .font(.headline)
                .foregroundColor(.white)
            
            MetricRow(label: "Total Workers", value: "\(workers.count)")
            MetricRow(label: "Active Workers", value: "\(workers.filter { $0.isActive }.count)")
            MetricRow(label: "Quarantined", value: "\(workers.filter { $0.isQuarantined }.count)")
            MetricRow(label: "With Failures", value: "\(workers.filter { $0.hasRecentFailure }.count)")
            MetricRow(label: "Total Failures", value: "\(analytics.totalFailures)")
            MetricRow(label: "Failure Rate", value: String(format: "%.1f%%", analytics.failureRate * 100))
            MetricRow(label: "Stale Workers (30d+)", value: "\(analytics.staleWorkers.count)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Helper Functions
    private func formatAge(_ seconds: TimeInterval) -> String {
        let days = Int(seconds / 86400)
        if days > 365 {
            return "\(days / 365)y"
        } else if days > 30 {
            return "\(days / 30)mo"
        } else if days > 0 {
            return "\(days)d"
        }
        return "\(Int(seconds / 3600))h"
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let emoji: String
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(emoji)
                    .font(.title2)
            }
            
            Text(value)
                .font(.title.bold())
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct ActivityBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 100)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: 100 * percentage)
            }
            
            Text("\(count)")
                .font(.headline.bold())
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct LifecycleRow: View {
    let icon: String
    let label: String
    let worker: String
    let age: TimeInterval
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.mint)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                Text(worker)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(formatAge(age))
                .font(.headline)
                .foregroundColor(.mint)
        }
    }
    
    private func formatAge(_ seconds: TimeInterval) -> String {
        let days = Int(seconds / 86400)
        if days > 365 { return "\(days / 365)y" }
        if days > 30 { return "\(days / 30)mo" }
        if days > 0 { return "\(days)d" }
        return "\(Int(seconds / 3600))h"
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
}
