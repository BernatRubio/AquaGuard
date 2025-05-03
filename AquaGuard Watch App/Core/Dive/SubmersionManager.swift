//
//  SubmersionManager.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import Foundation
import CoreMotion

@Observable class SubmersionManager: NSObject, CMWaterSubmersionManagerDelegate {
    
    private var manager: CMWaterSubmersionManager
    static let sharedInstance: SubmersionManager = createInstance()
    var diveSession: DiveSession?
    var cooldown: Int = 180
    
    private var persistenceController = PersistenceController.shared
    
    private init(manager: CMWaterSubmersionManager) {
        self.manager = manager
        super.init()
        self.manager.delegate = self // delegate begins to receive data as soon as you assign it
    }
    
    private static func createInstance() -> SubmersionManager {
        return SubmersionManager(manager: CMWaterSubmersionManager())
    }
    
    func manager(_ manager: CMWaterSubmersionManager, didUpdate event: CMWaterSubmersionEvent) {
    }
    
    func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterSubmersionMeasurement) {
        
        // If dive is not initialized, means we are in firstMeasurement
        if diveSession == nil {
            switch measurement.submersionState {
            case .unknown:
                break
            case .notSubmerged:
                break
            case .submergedShallow:
                break
            case .submergedDeep:
                diveSession = DiveSession(firstMeasurement: measurement)
                if diveSession != nil {
                    measurement.saveMeasurementToCoreData(manager: self)
                }
            case .approachingMaxDepth:
                break
            case .pastMaxDepth:
                break
            case .sensorDepthError:
                break
            @unknown default:
                break
            }
        } else {
            switch measurement.submersionState {
            case .unknown:
                break
            case .notSubmerged:
                // Dive finished – save the dive to Core Data and then reset it.
                if let diveSession = diveSession {
                    diveSession.saveDiveSessionToCoreData()
                }
                self.diveSession = nil
                break
            case .submergedShallow:
                if let diveSession = diveSession {
                    diveSession.segment(measurement: measurement)
                    measurement.saveMeasurementToCoreData(manager: self)
                    self.diveSession = self.diveSession // Trigger @Published
                }
            case .submergedDeep:
                if let diveSession = diveSession {
                    diveSession.segment(measurement: measurement)
                    measurement.saveMeasurementToCoreData(manager: self)
                    self.diveSession = self.diveSession // Trigger @Published
                }
            case .approachingMaxDepth:
                if let diveSession = diveSession {
                    diveSession.segment(measurement: measurement)
                    measurement.saveMeasurementToCoreData(manager: self)
                    self.diveSession = self.diveSession // Trigger @Published
                }
            case .pastMaxDepth:
                break
            case .sensorDepthError:
                break
            @unknown default:
                break
            }
        }
    }
    
    func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterTemperature) {
        if let diveSession = diveSession {
            diveSession.currentWaterTemperature = measurement.temperature
        }
    }
    
    func manager(_ manager: CMWaterSubmersionManager, errorOccurred error: any Error) {
    }
}
