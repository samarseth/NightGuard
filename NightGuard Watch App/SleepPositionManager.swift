import Foundation
import CoreMotion
import WatchKit

class SleepPositionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var currentPosition: SleepPosition = .unknown
    @Published var isMonitoring = false
    
    enum SleepPosition: String {
        case onBack = "On Back"
        case onStomach = "On Stomach"
        case onLeftSide = "On Left Side"
        case onRightSide = "On Right Side"
        case unknown = "Unknown"
    }
    
    init() {
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        // Update interval (in seconds)
        motionManager.deviceMotionUpdateInterval = 1.0
    }
    
    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        isMonitoring = true
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            
            // Get gravity vector
            let x = motion.gravity.x
            let y = motion.gravity.y
            let z = motion.gravity.z
            
            // Determine position based on gravity
            if z > 0.7 {
                self?.currentPosition = .onBack
            } else if z < -0.7 {
                self?.currentPosition = .onStomach
            } else if x > 0.7 {
                self?.currentPosition = .onLeftSide
            } else if x < -0.7 {
                self?.currentPosition = .onRightSide
            } else {
                self?.currentPosition = .unknown
            }
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        motionManager.stopDeviceMotionUpdates()
    }
}