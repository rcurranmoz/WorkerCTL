import Foundation

// MARK: - Pool Presets Database
struct PoolPresets {
    static let allPools: [PoolPreset] = [
        // From exact user list - macOS
        .init(workerType: "applicationservices-b-1-osx1015", name: "App Services L1", emoji: "📱", category: .macOS),
        .init(workerType: "applicationservices-b-3-osx1015", name: "App Services L3", emoji: "📱", category: .macOS),
        .init(workerType: "enterprise-1-b-osx-arm64", name: "Enterprise L1 ARM64", emoji: "🏢", category: .macOS),
        .init(workerType: "enterprise-3-b-osx-arm64", name: "Enterprise L3 ARM64", emoji: "🏢", category: .macOS),
        .init(workerType: "gecko-1-b-osx-1015", name: "Gecko Build L1 Catalina", emoji: "🏗️", category: .macOS),
        .init(workerType: "gecko-1-b-osx-1015-staging", name: "Gecko Build L1 Catalina Staging", emoji: "🧪", category: .macOS),
        .init(workerType: "gecko-1-b-osx-arm64", name: "Gecko Build L1 ARM64", emoji: "🏗️", category: .macOS),
        .init(workerType: "gecko-3-b-osx-1015", name: "Gecko Build L3 Catalina", emoji: "🏗️", category: .macOS),
        .init(workerType: "gecko-3-b-osx-arm64", name: "Gecko Build L3 ARM64", emoji: "🏗️", category: .macOS),
        .init(workerType: "gecko-t-osx-1015-r8", name: "Gecko Test Catalina R8", emoji: "🍎", category: .macOS),
        .init(workerType: "gecko-t-osx-1015-r8-staging", name: "Gecko Test Catalina R8 Staging", emoji: "🧪", category: .macOS),
        .init(workerType: "gecko-t-osx-1400-r8", name: "Gecko Test Intel R8", emoji: "⚡️", category: .macOS),
        .init(workerType: "gecko-t-osx-1400-r8-staging", name: "Gecko Test Intel R8 Staging", emoji: "🧪", category: .macOS),
        .init(workerType: "gecko-t-osx-1500-m4", name: "Gecko Test M4", emoji: "🚀", category: .macOS),
        .init(workerType: "gecko-t-osx-1500-m4-ipv6", name: "Gecko Test M4 IPv6", emoji: "🌐", category: .macOS),
        .init(workerType: "gecko-t-osx-1500-m4-staging", name: "Gecko Test M4 Staging", emoji: "🧪", category: .macOS),
        .init(workerType: "gecko-t-osx-1500-m-vms", name: "Gecko Test M-series VMs", emoji: "💻", category: .macOS),
        .init(workerType: "mozillavpn-b-1-osx", name: "Mozilla VPN L1", emoji: "🔐", category: .macOS),
        .init(workerType: "mozillavpn-b-3-osx", name: "Mozilla VPN L3", emoji: "🔐", category: .macOS),
        .init(workerType: "nss-1-b-osx-1015", name: "NSS L1 Catalina", emoji: "🔒", category: .macOS),
        .init(workerType: "nss-3-b-osx-1015", name: "NSS L3 Catalina", emoji: "🔒", category: .macOS),
        
        // From exact user list - Linux
        .init(workerType: "gecko-t-linux-netperf-1804", name: "Gecko Test Linux Netperf 18.04", emoji: "🌐", category: .linux),
        .init(workerType: "gecko-t-linux-netperf-2404", name: "Gecko Test Linux Netperf 24.04", emoji: "🌐", category: .linux),
        .init(workerType: "gecko-t-linux-talos-1804", name: "Gecko Test Linux Talos 18.04", emoji: "🐧", category: .linux),
        .init(workerType: "gecko-t-linux-talos-2404", name: "Gecko Test Linux Talos 24.04", emoji: "🐧", category: .linux),
        
        // From exact user list - Windows
        .init(workerType: "gecko-t-win7-32-hw", name: "Gecko Test Win7 32-bit", emoji: "🪟", category: .windows),
        .init(workerType: "win10-64-2009-hw", name: "Win10 64-bit 2009", emoji: "🪟", category: .windows),
        .init(workerType: "win10-64-2009-hw-alpha", name: "Win10 64-bit 2009 Alpha", emoji: "🧪", category: .windows),
        .init(workerType: "win11-64-24h2-hw", name: "Win11 64-bit 24H2", emoji: "🪟", category: .windows),
        .init(workerType: "win11-64-24h2-hw-alpha", name: "Win11 64-bit 24H2 Alpha", emoji: "🧪", category: .windows),
        .init(workerType: "win11-64-24h2-hw-perf-sheriff", name: "Win11 Perf Sheriff", emoji: "👮", category: .windows),
        .init(workerType: "win11-64-24h2-hw-ref", name: "Win11 Reference", emoji: "📚", category: .windows),
        .init(workerType: "win11-64-24h2-hw-ref-alpha", name: "Win11 Reference Alpha", emoji: "🧪", category: .windows),
        .init(workerType: "win11-64-24h2-hw-relops1213", name: "Win11 RelOps", emoji: "⚙️", category: .windows),
    ]
    
    static func categorized() -> [PoolCategory: [PoolPreset]] {
        Dictionary(grouping: allPools, by: { $0.category })
    }
}

// MARK: - Pool Preset Model
struct PoolPreset: Identifiable {
    let id = UUID()
    let workerType: String
    let name: String
    let emoji: String
    let category: PoolCategory
    let provisionerId = "releng-hardware" // All use same provisioner
    
    var displayName: String { name }
    var description: String { workerType }
}

// MARK: - Pool Categories
enum PoolCategory: String, CaseIterable {
    case macOS = "macOS"
    case windows = "Windows"
    case linux = "Linux"
    
    var emoji: String {
        switch self {
        case .macOS: return "🍎"
        case .windows: return "🪟"
        case .linux: return "🐧"
        }
    }
    
    var displayName: String {
        "\(emoji) \(rawValue)"
    }
}
