//
//  DecompressionController.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 2/5/25.
//

import Foundation

struct DecompressionController {
    static func updateDecompressionStop(for session: DiveSession) {
        let surfacePressure = session.surfacePressure.converted(to: .bars).value
        let maxGaugeCeiling = session.compartments.max(by: { $0.gaugeCeiling.value < $1.gaugeCeiling.value })?.gaugeCeiling.converted(to: .bars).value ?? 0.0
        let step = 0.3 // 0.3 bar increments
        let steps = ceil(maxGaugeCeiling / step)
        let rawStop = surfacePressure + steps * step
        let decompressionStop = rawStop == 0 ? 0 : ceil(rawStop / 0.3) * 0.3 // If decoStop is at 0 m, don't round it to 3 m
        let precision = 10.0 // for one decimal place
        let decompressionStopRounded = (decompressionStop * precision).rounded() / precision
        let measurementPressure: Measurement<UnitPressure> = .init(value: decompressionStopRounded, unit: .bars)
        session.decoState.currentStopGaugePressure = measurementPressure
        let measurementDepth: Measurement<UnitLength> = .init(value: UnitConverter.barToMeterSeaWater(decompressionStop), unit: .meters)
        session.decoState.currentStopDepth = measurementDepth
    }
    
    static func checkSafetyStop(for session: DiveSession) {
        let DESCENDING_THRESHOLD = 0.3
        let currentPressure = session.currentPressure.converted(to: .bars).value
        let surfacePressure = session.surfacePressure.converted(to: .bars).value
        let currentStopGaugePressure = session.decoState.currentStopGaugePressure.converted(to: .bars).value
        let decompressionStopPressure = currentStopGaugePressure + surfacePressure
        var lastDecoStopPressure: Double {
            if let lastDecoStopGaugePressure = session.decoState.decoStops.last?.gaugePressure.value {
                return lastDecoStopGaugePressure + surfacePressure
            }
            return Double(Int.max)
        }
        if currentPressure >= lastDecoStopPressure + DESCENDING_THRESHOLD {
            // If diving deeper than the last deco stop plus a threshold, reset deco stops and gradient factor
            session.decoState.decoStops = []
            session.gradientFactors.current = session.gradientFactors.low
        }
        
        if decompressionStopPressure >= currentPressure {
            if let index = session.decoState.decoStops.firstIndex(where: {$0.gaugePressure.value == decompressionStopPressure }) {
                // If the stop exists, we modify the stop end time
                session.decoState.decoStops[index].setEndTime()
            }
            else {
                session.decoState.decoStops.append(DecoStop(gaugePressure: session.decoState.currentStopGaugePressure))
            }
            
            guard let firstDecoStopGaugePressure = session.decoState.decoStops.first?.gaugePressure.value else { fatalError("Must have at least one deco stop to calculate gradient factor") }
            let firstDecoStopPressure = firstDecoStopGaugePressure + surfacePressure
            
            let gfHigh = session.gradientFactors.high
            let gfLow = session.gradientFactors.low
            let finalDecoStopPressure = surfacePressure + 0.3 // Final stop at 3 m
            
            let gfSlope = (gfHigh - gfLow) / (finalDecoStopPressure - firstDecoStopPressure)
            session.gradientFactors.current = (((gfSlope * (decompressionStopPressure - finalDecoStopPressure)) + gfHigh) * 100).rounded() / 100
        }
    }
}
