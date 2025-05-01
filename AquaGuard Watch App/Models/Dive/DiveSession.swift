//
//  DiveSession.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import Foundation
import CoreMotion

class DiveSession {
    let id = UUID().uuidString
    let startTime: Date
    var currentTime: Date
    var diveTime: TimeInterval
    let surfacePressure: Measurement<UnitPressure>
    var currentPressure: Measurement<UnitPressure>
    var currentDepth: Measurement<UnitLength>?
    
    var compartments: [TissueCompartment]
    var decoState: DecompressionState
    var gasMix: GasMix
    var gradientFactors: GradientFactorProfile
    
    init(firstMeasurement: CMWaterSubmersionMeasurement,
         config: DiveConfiguration = DiveConfiguration()
    ) {
        startTime = firstMeasurement.date
        currentTime = startTime
        diveTime = 0
        surfacePressure = firstMeasurement.surfacePressure.converted(to: .bars)
        guard let pressure = firstMeasurement.pressure?.converted(to: .bars) else {
            fatalError("Sensor returned invalid pressure")
        }
        currentPressure = pressure
        currentDepth = firstMeasurement.depth?.converted(to: .meters)
        
        gradientFactors = GradientFactorProfile(low: config.gfLow, high: config.gfHigh, current: config.gfLow)
        
        gasMix = GasMix(nitrogenPercentage: config.nitrogenPercentage, heliumPercentage: config.heliumPercentage)
        
        compartments = DiveSession.initializeCompartments(firstMeasurement: firstMeasurement, config: config)
        
        decoState = DiveSession.initializeDecompressionState(firstMeasurement: firstMeasurement)
    }
    
    func segment(measurement: CMWaterSubmersionMeasurement) {
        TissueGasSimulator.updateCompartments(session: self, measurement: measurement)
    }
    
    private static func initializeCompartments(
        firstMeasurement: CMWaterSubmersionMeasurement,
        config: DiveConfiguration
    ) -> [TissueCompartment] {
        var compartments: [TissueCompartment] = []

        let surfacePressure = firstMeasurement.surfacePressure.converted(to: .bars).value
        let nitrogenPressure = calculateAlveolarPressure(Pamb: surfacePressure, Q: config.nitrogenPercentage, RQ: config.respiratoryQuotient)

        for i in 0..<ZHL16_N2.count {
            let nitrogenComponent = TissueGasComponent(
                halfTime: ZHL16_N2[i].halfTime,
                a: ZHL16_N2[i].a,
                b: ZHL16_N2[i].b,
                pressure: nitrogenPressure
            )

            let heliumComponent = TissueGasComponent(
                halfTime: ZHL16_He[i].halfTime,
                a: ZHL16_He[i].a,
                b: ZHL16_He[i].b,
                pressure: 0.0
            )

            let compartment = TissueCompartment(
                compartmentNumber: i + 1,
                nitrogen: nitrogenComponent,
                helium: heliumComponent,
                modificationDate: Date()
            )

            compartments.append(compartment)
        }

        return compartments
    }
    
    private static func initializeDecompressionState(
        firstMeasurement: CMWaterSubmersionMeasurement
    ) -> DecompressionState {
        return DecompressionState(decoStops: [], currentStopDepth: firstMeasurement.depth?.converted(to: .meters))
    }
}
