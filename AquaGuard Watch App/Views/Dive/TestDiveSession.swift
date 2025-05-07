//
//  TestDiveSession.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import Foundation
import CoreMotion

extension DiveSession {
    static func previewSession() -> DiveSession {
        let now = Date()
        
        // 1) Default pressures, depth & temp:
        let surfaceP = Measurement(value: 1.0, unit: UnitPressure.bars)
        let depth   = Measurement(value: 0.0, unit: UnitLength.meters)
        let temp    = Measurement(value: 20.0, unit: UnitTemperature.celsius)
        
        // 2) Default gas mix & RQ:
        let gasMix = GasMix(nitrogenPercentage: 79.0, heliumPercentage: 21.0)
        let rq     = 0.85
        
        // 3) Compute inspired partial pressures:
        let pN2 = Measurement(
            value: surfaceP.value * gasMix.nitrogenPercentage / 100.0,
            unit: surfaceP.unit
        )
        let pHe = Measurement(
            value: surfaceP.value * gasMix.heliumPercentage / 100.0,
            unit: surfaceP.unit
        )
        
        // 4) Build 16 tissue compartments at equilibrium:
        let compartments: [TissueCompartment] = (1...16).map { idx in
            TissueCompartment(
                compartmentNumber: idx,
                nitrogen: TissueGasComponent(halfTime: 5.0, a: 1.0, b: 2.0, pressure: pN2),
                helium:   TissueGasComponent(halfTime: 5.0, a: 1.0, b: 2.0, pressure: pHe),
                gaugeCeiling:  .init(value: 0.0, unit: .bars),
                modificationDate: now
            )
        }
        
        // 5) Start with no deco stops:
        let decoState = DecompressionState(
            decoStops:       [],
            currentStopGaugePressure:     .init(value: 0.0, unit: .bars),
            currentStopDepth: depth
        )
        
        // 6) Default gradient factors:
        let gf = GradientFactorProfile(low: 0.3, high: 0.8, current: 0.3)
        
        return DiveSession(
            startTime:              now,
            currentTime:            now,
            diveTime:               0,
            surfacePressure:        surfaceP,
            currentPressure:        surfaceP,
            currentDepth:           depth,
            currentWaterTemperature: temp,
            respiratoryQuotient:    rq,
            compartments:           compartments,
            decoState:              decoState,
            gasMix:                 gasMix,
            gradientFactors:        gf
        )
    }
}
