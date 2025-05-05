//
//  DecompressionController.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 2/5/25.
//

import Foundation

struct DecompressionController {
    static func updateSafetyStop(for session: DiveSession) {
        let surfacePressure = session.surfacePressure.converted(to: .bars).value
        let maxCeiling = session.compartments.max(by: { $0.ceiling.value < $1.ceiling.value })?.ceiling.converted(to: .bars).value ?? 0.0
        let step = 0.3 // 0.3 bar increments
        let steps = ceil(maxCeiling / step)
        let safetyStop = surfacePressure + steps * step
        let precision = 10.0 // for one decimal place
        let safetyStopRounded = (safetyStop * precision).rounded() / precision
        let measurementPressure: Measurement<UnitPressure> = .init(value: safetyStopRounded, unit: .bars)
        session.decoState.currentStop = measurementPressure
        let measurementDepth: Measurement<UnitLength> = .init(value: UnitConverter.barToMeterSeaWater(maxCeiling), unit: .meters)
        session.decoState.currentStopDepth = measurementDepth
    }
    
    static func checkSafetyStop(for session: DiveSession) {
        let DESCENDING_THRESHOLD = 0.3
        let currentPressure = session.currentPressure.converted(to: .bars).value
        let safetyStopPressure = session.decoState.currentStop.converted(to: .bars).value
        if currentPressure >= (session.decoState.decoStops.last?.pressure.value ?? Double(Int.max)) + DESCENDING_THRESHOLD {
            // If diving deeper than the last deco stop plus a threshold, reset deco stops and gradient factor
            session.decoState.decoStops = []
            session.gradientFactors.current = session.gradientFactors.low
        }
        
        if safetyStopPressure >= currentPressure {
            if let index = session.decoState.decoStops.firstIndex(where: {$0.pressure.value == safetyStopPressure }) {
                // If the stop exists, we modify the stop end time
                session.decoState.decoStops[index].setEndTime()
            }
            else {
                session.decoState.decoStops.append(DecoStop(pressure: session.decoState.currentStop))
            }
            
            guard let firstStopPressure = session.decoState.decoStops.first?.pressure.value else { fatalError("Must have at least one deco stop to calculate gradient factor") }
            
            let gfHigh = session.gradientFactors.high
            let gfLow = session.gradientFactors.low
            let finalStopPressure = session.surfacePressure.converted(to: .bars).value
            
            let gfSlope = (gfHigh - gfLow) / (finalStopPressure - firstStopPressure)
            session.gradientFactors.current = (((gfSlope * (safetyStopPressure - finalStopPressure)) + gfHigh) * 100).rounded() / 100
        }
    }
}
