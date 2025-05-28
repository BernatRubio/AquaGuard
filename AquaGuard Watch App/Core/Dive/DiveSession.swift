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
        
        decoState = DiveSession.initializeDecompressionState(surfacePressure: surfacePressure)
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
    
    func getLowestCeiling() -> Measurement<UnitPressure> {
        var lowestCeiling = self.decoState.gfLowPressureThisDive.converted(to: .bars).value
        let gfLow = self.gradientFactors.low
        
        for compartment in self.compartments {
            let an = compartment.nitrogen.a
            let bn = compartment.nitrogen.b
            let Pn = compartment.nitrogen.pressure.converted(to: .bars).value
            let ahe = compartment.helium.a
            let bhe = compartment.helium.b
            let Phe = compartment.helium.pressure.converted(to: .bars).value
            
            let P = Pn + Phe
            let a = (an * Pn + ahe * Phe) / P
            let b = (bn * Pn + bhe * Phe) / P
            
            let tissueLowestCeiling = (b * P - gfLow * a * b) / ((1.0 - b) * gfLow + b)
            lowestCeiling = max(lowestCeiling, tissueLowestCeiling)
        }
        
        let lowestCeilingObj: Measurement<UnitPressure> = .init(value: lowestCeiling, unit: .bars)
        self.decoState.gfLowPressureThisDive = lowestCeilingObj
        
        return lowestCeilingObj
    }
    
    func updateCompartmentsCeilings() {
        let surfacePressure = self.surfacePressure
        let gfHigh = self.gradientFactors.high
        let gfLow = self.gradientFactors.low
        var retToleranceLimitAmbientPressure: Double = 0.0
        
        let gfLowPressureThisDive = getLowestCeiling()
        
        for i in 0..<self.compartments.count {
            let an = self.compartments[i].nitrogen.a
            let bn = self.compartments[i].nitrogen.b
            let Pn = self.compartments[i].nitrogen.pressure
            let ahe = self.compartments[i].helium.a
            let bhe = self.compartments[i].helium.b
            let Phe = self.compartments[i].helium.pressure
            
            let tolerated = calculateCeilingGaugePressure(Pn: Pn, an: an, bn: bn, Phe: Phe, ahe: ahe, bhe: bhe, surfacePressure: surfacePressure, gfHigh: gfHigh, gfLow: gfLow, gfLowPressureThisDive: gfLowPressureThisDive, retToleranceLimitAmbientPressure: retToleranceLimitAmbientPressure)
            
            self.compartments[i].gaugeCeiling = tolerated
            
            let toleratedValue = tolerated.converted(to: .bars).value
            
            if (toleratedValue >= retToleranceLimitAmbientPressure) {
                retToleranceLimitAmbientPressure = toleratedValue
            }
        }
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

            let compartment = TissueCompartment(
                compartmentNumber: i + 1,
                nitrogen: nitrogenComponent,
                helium: heliumComponent,
                gaugeCeiling: .init(value: 0.0, unit: .bars),
                modificationDate: Date()
            )

            compartments.append(compartment)
        }

        return compartments
    }
    
    private static func initializeDecompressionState(surfacePressure: Measurement<UnitPressure>) -> DecompressionState {
        let depth: Measurement<UnitLength> = .init(value: 0, unit: .meters)
        let gfLowPressureThisDive = surfacePressure.converted(to: .bars).value + 1.0
        return DecompressionState(decoStops: [], currentStopGaugePressure: .init(value: 0.0, unit: .bars), currentStopDepth: depth, gfLowPressureThisDive: .init(value: gfLowPressureThisDive, unit: .bars))
    }
}
