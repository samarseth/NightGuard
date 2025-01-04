import Foundation
import CoreMotion
import WatchKit

class SleepPositionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private var simulatorTimer: Timer?
    private let hapticEngine = WKInterfaceDevice.current()
    private let healthManager = HealthKitManager()
    private var backPositionTimer: Timer?
    
    @Published var currentPosition: String = "Unknown"
    @Published var isMonitoring = false
    @Published var timeInPosition: TimeInterval = 0
    @Published var positionHistory: [(position: String, timestamp: Date)] = []
    @Published var sessionStartTime: Date?
    
    // Settings
    @Published var vibrateOnBack = true
    @Published var saveToHealth = true
    @Published var backWarningDelay: TimeInterval = 5 // Seconds before vibrating
    
    private func playHapticWarning() {
        // Play a strong haptic warning
        hapticEngine.play(.notification)
        
        // Follow up with two quick taps
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.hapticEngine.play(.click)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.hapticEngine.play(.click)
            }
        }
    }
    
    private func updatePosition(_ newPosition: String) {
        if currentPosition != newPosition {
            currentPosition = newPosition
            positionHistory.append((position: newPosition, timestamp: Date()))
            
            // Handle back position timer
            if newPosition == "On Back" && vibrateOnBack {
                // Start timer for back position warning
                backPositionTimer?.invalidate()
                backPositionTimer = Timer.scheduledTimer(withTimeInterval: backWarningDelay, repeats: false) { [weak self] _ in
                    self?.playHapticWarning()
                }
                print("Started back position timer")
            } else {
                // Cancel timer if not on back
                backPositionTimer?.invalidate()
                backPositionTimer = nil
            }
        }
    }
    
    func startMonitoring() {
        print("startMonitoring called")
        isMonitoring = true
        sessionStartTime = Date()
        
        #if targetEnvironment(simulator)
        print("Running in simulator - using simulated data")
        simulatorTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            let positions = ["On Back", "On Stomach", "On Left Side", "On Right Side"]
            let newPosition = positions.randomElement() ?? "Unknown"
            self?.updatePosition(newPosition)
        }
        #else
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
                guard let motion = motion else { return }
                
                let x = motion.gravity.x
                let y = motion.gravity.y
                let z = motion.gravity.z
                
                let newPosition: String
                if z > 0.7 {
                    newPosition = "On Back"
                } else if z < -0.7 {
                    newPosition = "On Stomach"
                } else if x > 0.7 {
                    newPosition = "On Left Side"
                } else if x < -0.7 {
                    newPosition = "On Right Side"
                } else {
                    newPosition = "Unknown"
                }
                
                self?.updatePosition(newPosition)
            }
        }
        #endif
    }
    
    func stopMonitoring() {
        print("stopMonitoring called")
        isMonitoring = false
        
        // Clean up timers
        backPositionTimer?.invalidate()
        backPositionTimer = nil
        
        #if targetEnvironment(simulator)
        simulatorTimer?.invalidate()
        simulatorTimer = nil
        #else
        motionManager.stopDeviceMotionUpdates()
        #endif
        
        if saveToHealth, let startTime = sessionStartTime {
            Task {
                do {
                    try await healthManager.saveSleepData(
                        startDate: startTime,
                        endDate: Date(),
                        sleepPosition: positionHistory.map { $0.position }.joined(separator: ", ")
                    )
                } catch {
                    print("Failed to save to HealthKit: \(error)")
                }
            }
        }
        
        sessionStartTime = nil
    }
    
    func clearHistory() {
        positionHistory.removeAll()
    }
}
