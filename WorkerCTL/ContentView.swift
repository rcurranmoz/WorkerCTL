import SwiftUI

struct WorkerPool: Identifiable, Codable {
    let id = UUID()
    let provisionerId: String
    let workerType: String
    let displayName: String
    let description: String
    var emoji: String
    
    static let defaultPools = [
        WorkerPool(
            provisionerId: "releng-hardware",
            workerType: "gecko-t-osx-1500-m4",
            displayName: "M4 Mac mini",
            description: "Apple M4 macOS workers",
            emoji: "🚀"
        ),
        WorkerPool(
            provisionerId: "releng-hardware",
            workerType: "gecko-t-osx-1400-r8",
            displayName: "Intel Mac",
            description: "Intel Xeon macOS workers",
            emoji: "⚡️"
        ),
    ]
}

struct ContentView: View {
    @State private var workerPools = WorkerPool.defaultPools
    @State private var showingAddPool = false
    @State private var showingInfo = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fun animated gradient background
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
                        // Header with fun tagline
                        VStack(spacing: 8) {
                            Text("WorkerCTL")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("🎮 Control Your Worker Fleet")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Worker pools
                        LazyVStack(spacing: 16) {
                            ForEach(workerPools) { pool in
                                NavigationLink(destination: WorkerListView(
                                    provisionerId: pool.provisionerId,
                                    workerType: pool.workerType
                                )) {
                                    FunPoolCard(pool: pool)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Quick add button
                        Button {
                            showingAddPool = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Add Worker Pool")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingInfo = true
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddPool) {
                QuickAddPoolView(workerPools: $workerPools)
            }
            .sheet(isPresented: $showingInfo) {
                InfoView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FunPoolCard: View {
    let pool: WorkerPool
    
    var body: some View {
        HStack(spacing: 16) {
            // Big emoji
            Text(pool.emoji)
                .font(.system(size: 50))
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(pool.displayName)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Text(pool.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(spacing: 4) {
                    Text(pool.workerType)
                        .font(.caption.monospaced())
                        .foregroundColor(.blue.opacity(0.8))
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct QuickAddPoolView: View {
    @Binding var workerPools: [WorkerPool]
    @Environment(\.dismiss) private var dismiss
    
    @State private var quickMode = true
    @State private var selectedPreset = 0
    @State private var customProvisionerId = "releng-hardware"
    @State private var customWorkerType = ""
    @State private var displayName = ""
    @State private var description = ""
    @State private var selectedEmoji = "🖥️"
    
    let presets = [
        ("gecko-t-win10-64", "Windows 10 x64", "Windows 10 64-bit workers", "🪟"),
        ("gecko-t-win11-64", "Windows 11 x64", "Windows 11 64-bit workers", "🪟"),
        ("gecko-t-linux-1804", "Linux Ubuntu 18.04", "Ubuntu 18.04 Linux workers", "🐧"),
        ("gecko-t-osx-1015", "macOS Catalina", "macOS 10.15 workers", "🍎"),
    ]
    
    let emojiOptions = ["🚀", "⚡️", "🖥️", "💻", "🎮", "🔥", "⭐️", "🎯", "🪟", "🐧", "🍎", "🤖", "🦊"]
    
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
                    VStack(spacing: 24) {
                        // Mode picker
                        Picker("Mode", selection: $quickMode) {
                            Text("Quick Add 🎯").tag(true)
                            Text("Custom 🔧").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        if quickMode {
                            // Quick mode - select from presets
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Select a common pool:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(presets.indices, id: \.self) { index in
                                    Button {
                                        selectedPreset = index
                                        let preset = presets[index]
                                        customWorkerType = preset.0
                                        displayName = preset.1
                                        description = preset.2
                                        selectedEmoji = preset.3
                                    } label: {
                                        HStack {
                                            Text(presets[index].3)
                                                .font(.system(size: 40))
                                            
                                            VStack(alignment: .leading) {
                                                Text(presets[index].1)
                                                    .font(.headline)
                                                Text(presets[index].0)
                                                    .font(.caption.monospaced())
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedPreset == index {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.title2)
                                            }
                                        }
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(selectedPreset == index ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedPreset == index ? Color.blue : Color.white.opacity(0.2), lineWidth: selectedPreset == index ? 2 : 1)
                                        )
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        } else {
                            // Custom mode
                            VStack(spacing: 20) {
                                CustomTextField(title: "Display Name", text: $displayName, placeholder: "My Worker Pool")
                                CustomTextField(title: "Description", text: $description, placeholder: "What these workers do")
                                CustomTextField(title: "Provisioner ID", text: $customProvisionerId, placeholder: "releng-hardware")
                                CustomTextField(title: "Worker Type", text: $customWorkerType, placeholder: "gecko-t-...")
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Choose an emoji:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(emojiOptions, id: \.self) { emoji in
                                                Button {
                                                    selectedEmoji = emoji
                                                } label: {
                                                    Text(emoji)
                                                        .font(.system(size: 36))
                                                        .frame(width: 60, height: 60)
                                                        .background(
                                                            Circle()
                                                                .fill(selectedEmoji == emoji ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                                                        )
                                                        .overlay(
                                                            Circle()
                                                                .stroke(selectedEmoji == emoji ? Color.blue : Color.clear, lineWidth: 2)
                                                        )
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Add Worker Pool")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addPool()
                    }
                    .foregroundColor(.blue)
                    .disabled(customWorkerType.isEmpty || customProvisionerId.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func addPool() {
        let newPool = WorkerPool(
            provisionerId: customProvisionerId,
            workerType: customWorkerType,
            displayName: displayName.isEmpty ? customWorkerType : displayName,
            description: description.isEmpty ? "Custom worker pool" : description,
            emoji: selectedEmoji
        )
        workerPools.append(newPool)
        dismiss()
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
                .foregroundColor(.white)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        }
        .padding(.horizontal)
    }
}

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
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
                    VStack(spacing: 24) {
                        // App icon
                        Image(systemName: "server.rack")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding()
                        
                        Text("WorkerCTL")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Control your Taskcluster worker fleet from iOS")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            InfoRow(icon: "🚀", title: "Real-time Monitoring", description: "View worker status and activity live")
                            InfoRow(icon: "🔍", title: "Smart Filtering", description: "Find quarantined or inactive workers instantly")
                            InfoRow(icon: "📊", title: "Pool Stats", description: "See total, active, and quarantined counts")
                            InfoRow(icon: "🔗", title: "Deep Links", description: "Jump to Taskcluster web UI for details")
                            InfoRow(icon: "⚡️", title: "Zero Config", description: "Works with public APIs - no setup needed!")
                        }
                        .padding()
                        
                        VStack(spacing: 8) {
                            Text("Built for Mozilla Release Engineering")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("Active status: last seen within 24 hours")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding()
                    }
                    .padding(.vertical)
                }
            }
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
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
