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
    var currentDepth: Measurement<UnitLength>
    var currentWaterTemperature: Measurement<UnitTemperature> = Measurement(value: 0, unit: .celsius)
    
    let respiratoryQuotient: Double
    
    var compartments: [TissueCompartment]
    var decoState: DecompressionState
    var gasMix: GasMix
    var gradientFactors: GradientFactorProfile
    
    let diveEntity = DiveEntity(context: PersistenceController.shared.container.viewContext)
    
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
        guard let depth = firstMeasurement.depth?.converted(to: .meters) else {
            fatalError("Sensor returned invalid depth")
        }
        currentDepth = depth
        
        respiratoryQuotient = config.respiratoryQuotient
        
        gradientFactors = GradientFactorProfile(low: config.gfLow, high: config.gfHigh, current: config.gfLow)
        
        gasMix = GasMix(nitrogenPercentage: config.nitrogenPercentage, heliumPercentage: config.heliumPercentage)
        
        compartments = DiveSession.initializeCompartments(firstMeasurement: firstMeasurement, config: config)
        
        decoState = DiveSession.initializeDecompressionState()
    }
    
    // Init for previews
    public init(
          id: String = UUID().uuidString,
          startTime: Date,
          currentTime: Date,
          diveTime: TimeInterval,
          surfacePressure: Measurement<UnitPressure>,
          currentPressure: Measurement<UnitPressure>,
          currentDepth: Measurement<UnitLength>,
          currentWaterTemperature: Measurement<UnitTemperature>,
          respiratoryQuotient: Double,
          compartments: [TissueCompartment],
          decoState: DecompressionState,
          gasMix: GasMix,
          gradientFactors: GradientFactorProfile
        ) {
          self.startTime              = startTime
          self.currentTime            = currentTime
          self.diveTime               = diveTime
          self.surfacePressure        = surfacePressure
          self.currentPressure        = currentPressure
          self.currentDepth           = currentDepth
          self.currentWaterTemperature = currentWaterTemperature
          self.respiratoryQuotient    = respiratoryQuotient
          self.compartments           = compartments
          self.decoState              = decoState
          self.gasMix                 = gasMix
          self.gradientFactors        = gradientFactors
        }
    
    func segment(measurement: CMWaterSubmersionMeasurement) {
        TissueGasSimulator.updateCompartments(session: self, measurement: measurement)
        CompartmentPersistence.persistCompartments(in: PersistenceController.shared.container.viewContext, for: self)
        DecompressionController.updateDecompressionStop(for: self)
        
        diveTime = measurement.date.timeIntervalSince(startTime)
        currentPressure = measurement.pressure?.converted(to: .bars) ?? currentPressure
        currentDepth = measurement.depth?.converted(to: .meters) ?? currentDepth
        currentTime = measurement.date
        
        debug(measurement: measurement)
    }
    
    private static func initializeCompartments(
        firstMeasurement: CMWaterSubmersionMeasurement,
        config: DiveConfiguration
    ) -> [TissueCompartment] {
        var compartments: [TissueCompartment] = []

        let surfacePressure = firstMeasurement.surfacePressure.converted(to: .bars)
        let nitrogenPressure = calculateAlveolarPressure(Pamb: surfacePressure.value, Q: config.nitrogenPercentage, RQ: config.respiratoryQuotient)

        for i in 0..<ZHL16_N2.count {
            let nitrogenComponent = TissueGasComponent(
                halfTime: ZHL16_N2[i].halfTime,
                a: ZHL16_N2[i].a,
                b: ZHL16_N2[i].b,
                pressure: .init(value: nitrogenPressure, unit: .bars)
            )

            let heliumComponent = TissueGasComponent(
                halfTime: ZHL16_He[i].halfTime,
                a: ZHL16_He[i].a,
                b: ZHL16_He[i].b,
                pressure: .init(value: 0.0, unit: .bars)
            )
            
            let ceilingPressure = calculateCeilingGaugePressure(Pn: nitrogenPressure, an: ZHL16_N2[i].a, bn: ZHL16_N2[i].b, gf: config.gfHigh, surfacePressure: surfacePressure)

            let compartment = TissueCompartment(
                compartmentNumber: i + 1,
                nitrogen: nitrogenComponent,
                helium: heliumComponent,
                gaugeCeiling: ceilingPressure,
                modificationDate: Date()
            )

            compartments.append(compartment)
        }

        return compartments
    }
    
    private static func initializeDecompressionState() -> DecompressionState {
        let depth: Measurement<UnitLength> = .init(value: 0, unit: .meters)
        return DecompressionState(decoStops: [], currentStopGaugePressure: .init(value: 0.0, unit: .bars), currentStopDepth: depth)
    }
}
