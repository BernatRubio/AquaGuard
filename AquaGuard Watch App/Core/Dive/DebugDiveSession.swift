//
//  DebugDiveSession.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 4/5/25.
//

import CoreMotion

extension DiveSession {
    func debug(measurement: CMWaterSubmersionMeasurement) {
        let currentStopDepth = decoState.currentStopDepth.converted(to: .meters)
        print("**------------------------------------**")
        print("DiveTime: \(diveTime)")
        print("CurrentPressure: \(String(describing: measurement.pressure))")
        print("CurrentDepth: \(String(describing: measurement.depth))")
        print("SurfacePressure: \(String(describing: measurement.surfacePressure))")
        print("SubmersionState: \(String(describing: measurement.submersionState))")
        print("CurrentSafetyStopDepth: \(currentStopDepth.value) \(currentStopDepth.unit.symbol)")
        print("WaterTemperature: \(String(describing: currentWaterTemperature.value)) \(currentWaterTemperature.unit.symbol)")
    }
}
