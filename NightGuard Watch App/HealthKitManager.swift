//
//  HealthKitManager.swift
//  NightGuard
//
//  Created by Samar Seth
//


import Foundation
import HealthKit

class HealthKitManager {
    private let healthStore = HKHealthStore()
    
    func saveSleepData(startDate: Date, endDate: Date, sleepPosition: String) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthError.notAvailable
        }
        
        // Create category type for sleep analysis
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthError.typesNotAvailable
        }
        
        // Request authorization if not already granted
        let typesToShare: Set = [sleepType]
        let typesToRead: Set = [sleepType]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            
            // Create sleep sample
            let sleepCategory = HKCategoryValueSleepAnalysis.asleep.rawValue
            let metadata: [String: Any] = ["sleep_position": sleepPosition]
            
            let sample = HKCategorySample(
                type: sleepType,
                value: sleepCategory,
                start: startDate,
                end: endDate,
                metadata: metadata
            )
            
            try await healthStore.save(sample)
            print("Successfully saved sleep data to HealthKit")
            
        } catch {
            print("Error saving to HealthKit: \(error)")
            throw HealthError.saveFailed
        }
    }
    
    func fetchSleepData() async throws -> [(Date, Date, String)] {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthError.notAvailable
        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthError.typesToRead
        }
        
        // Create query to fetch sleep data
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: nil,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                return
            }
            
            // Process samples
            for sample in samples {
                if let position = sample.metadata?["sleep_position"] as? String {
                    print("Sleep position: \(position), Start: \(sample.startDate), End: \(sample.endDate)")
                }
            }
        }
        
        try healthStore.execute(query)
        return []
    }
    
    enum HealthError: Error {
        case notAvailable
        case typesNotAvailable
        case saveFailed
        case typesToRead
    }
}
