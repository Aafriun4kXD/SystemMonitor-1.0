import SwiftUI

struct ContentView: View {
    @StateObject private var monitor = MonitoringService()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        StatCard(
                            icon: "cpu",
                            title: "CPU Usage",
                            value: String(format: "%.1f%%", monitor.stats.cpuUsage),
                            color: .blue
                        )
                        
                        StatCard(
                            icon: "memorychip",
                            title: "RAM",
                            value: String(format: "%.0f MB", monitor.stats.ramUsed),
                            subtitle: String(format: "of %.0f MB (%.1f%%)", 
                                           monitor.stats.ramTotal,
                                           monitor.stats.ramPercentage),
                            color: .green
                        )
                        
                        StatCard(
                            icon: "battery.100",
                            title: "Battery",
                            value: "\(monitor.stats.batteryLevel)%",
                            subtitle: monitor.stats.batteryState,
                            color: monitor.stats.batteryLevel < 20 ? .red : .orange
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("System Monitor")
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var subtitle: String = ""
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
}