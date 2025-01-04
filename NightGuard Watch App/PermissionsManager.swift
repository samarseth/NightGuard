import Foundation
import CoreMotion
import HealthKit

class PermissionsManager: ObservableObject {
    @Published var motionAuthorized = false
    @Published var healthAuthorized = false
    
    private let healthStore = HKHealthStore()
    private let motionManager = CMMotionManager()
    
    func requestPermissions() async {
        await requestHealthPermissions()
        await requestMotionPermissions()
    }
    
    private func requestHealthPermissions() async {
        // Define the health data types we want to access
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let typesToRead: Set<HKSampleType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            await MainActor.run {
                self.healthAuthorized = true
            }
        } catch {
            print("Error requesting HealthKit authorization: \(error)")
        }
    }
    
    private func requestMotionPermissions() async {
        // Motion permission is handled through Info.plist
        // We can check if motion data is available
        await MainActor.run {
            self.motionAuthorized = motionManager.isDeviceMotionAvailable
        }
    }
}