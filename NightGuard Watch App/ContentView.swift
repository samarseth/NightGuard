import SwiftUI

struct ContentView: View {
    @StateObject private var positionManager = SleepPositionManager()
    @AppStorage("hasShownPermissions") private var hasShownPermissions = false
    @State private var showPermissions = false
    
    var body: some View {
        TabView {
            MonitoringView(positionManager: positionManager)
                .tabItem {
                    Label("Monitor", systemImage: "bed.double.fill")
                }
            
            StatsView(positionManager: positionManager)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            SettingsView(positionManager: positionManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .sheet(isPresented: $showPermissions) {
            PermissionsView(showPermissions: $showPermissions)
        }
        .onAppear {
            if !hasShownPermissions {
                showPermissions = true
                hasShownPermissions = true
            }
        }
    }
}

struct MonitoringView: View {
    @ObservedObject var positionManager: SleepPositionManager
    
    var body: some View {
        VStack {
            Text(positionManager.isMonitoring ? "Monitoring Sleep" : "Start Monitoring")
                .font(.system(.title3, design: .rounded))
            
            Button(action: {
                if positionManager.isMonitoring {
                    positionManager.stopMonitoring()
                } else {
                    positionManager.startMonitoring()
                }
            }) {
                Image(systemName: positionManager.isMonitoring ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(positionManager.isMonitoring ? .red : .green)
            }
            .buttonStyle(PlainButtonStyle())
            
            if positionManager.isMonitoring {
                Text("Current Position")
                    .font(.headline)
                Text(positionManager.currentPosition)
                    .font(.title2)
                    .padding()
            }
        }
    }
}

struct StatsView: View {
    @ObservedObject var positionManager: SleepPositionManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Position History")
                    .font(.headline)
                
                if positionManager.positionHistory.isEmpty {
                    Text("No data yet")
                        .foregroundColor(.gray)
                } else {
                    ForEach(positionManager.positionHistory.reversed(), id: \.timestamp) { entry in
                        HStack {
                            Text(entry.position)
                                .font(.body)
                            Spacer()
                            Text(formatTime(entry.timestamp))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SettingsView: View {
    @ObservedObject var positionManager: SleepPositionManager
    
    var body: some View {
        List {
            Section("Notifications") {
                Toggle("Vibrate on Back", isOn: $positionManager.vibrateOnBack)
                if positionManager.vibrateOnBack {
                    Picker("Warning Delay", selection: $positionManager.backWarningDelay) {
                        Text("5 seconds").tag(TimeInterval(5))
                        Text("10 seconds").tag(TimeInterval(10))
                        Text("30 seconds").tag(TimeInterval(30))
                        Text("1 minute").tag(TimeInterval(60))
                    }
                }
            }
            
            Section("Health") {
                Toggle("Save to Health", isOn: $positionManager.saveToHealth)
            }
            
            Section {
                Button(action: {
                    positionManager.clearHistory()
                }) {
                    Text("Clear History")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
