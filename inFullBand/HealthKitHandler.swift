//
//  HandleHealthKit.swift
//  Mi Band Test
//
//  Created by Stefan Bethge on 17.04.18.
//  Copyright © 2018 Stefan Bethge. All rights reserved.
//

import HealthKit

class HealthKitHandler {
    var healthKitStore = HKHealthStore()
    
    required init(completion: @escaping (Bool, String) -> Swift.Void) {
        //1. Check to see if HealthKit is available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, "HealthKit not available")
            return
        }
        
        //2. Prepare the data types that will interact with HealthKit
        guard let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false, "Health data for Heart Rate not available")
            return
        }
        
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [heartRate]
        //let healthKitTypesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]
        
        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: nil) { (success, error) in
                                                completion(success, error.debugDescription)
        }
    }
    
    func saveHeartRate(date: Date = Date(), heartRate heartRateValue: Double, completion completionBlock: @escaping (Bool, Error?) -> Void) {
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let quantity = HKQuantity(unit: unit, doubleValue: heartRateValue)
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let heartRateSample = HKQuantitySample(type: type, quantity: quantity, start: date, end: date)
        
        self.healthKitStore.save(heartRateSample) { (success, error) -> Void in
            if !success {
                print("An error occured saving the HR sample \(heartRateSample). In your app, try to handle this gracefully. The error was: \(error).")
            }
            completionBlock(success, error)
        }
    }
}
