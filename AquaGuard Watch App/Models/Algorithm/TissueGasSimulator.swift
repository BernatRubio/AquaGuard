//
//  TissueGasSimulator.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import CoreMotion

struct TissueGasSimulator {
    static let config = DiveConfiguration()
    
    static func updateCompartments(session: DiveSession, measurement: CMWaterSubmersionMeasurement) {
        let oldPressureInBars = session.currentPressure.converted(to: .bars).value
        guard let newPressureInBars = measurement.pressure?.converted(to: .bars).value else { fatalError("Sensor returned invalid pressure") }
        let segmentTime = (measurement.date.timeIntervalSince(session.currentTime) * 1000).rounded() / 1000 // Approx. 0.333 seconds if called 3 times per second
        guard segmentTime > 0 else { fatalError("Segment time must be greater than zero") }
        
        for i in 0..<ZHL16_N2.count {
            guard let nitrogenPressure = session.compartments[i].nitrogen.pressure else {fatalError("Must have a valid nitrogen pressure")}
            
            let pn = schreinerEquation(
                Pi: nitrogenPressure,
                Palv: calculateAlveolarPressure(Pamb: newPressureInBars, Q: session.gasMix.nitrogenPercentage, RQ: config.respiratoryQuotient),
                t: segmentTime,
                R: calculateGasRate(d0: oldPressureInBars, dt: newPressureInBars, t: segmentTime, Q: session.gasMix.nitrogenPercentage),
                k: decayConstant(fromHalfTime: session.compartments[i].nitrogen.halfTime)
            )
            
            session.compartments[i].nitrogen.pressure = pn
            
            guard let heliumPressure = session.compartments[i].helium.pressure else {fatalError("Must have a valid helium pressure")}
            
            let ph = schreinerEquation(
                Pi: heliumPressure,
                Palv: calculateAlveolarPressure(Pamb: newPressureInBars, Q: session.gasMix.heliumPercentage, RQ: config.respiratoryQuotient),
                t: segmentTime,
                R: calculateGasRate(d0: oldPressureInBars, dt: newPressureInBars, t: segmentTime, Q: session.gasMix.heliumPercentage),
                k: decayConstant(fromHalfTime: session.compartments[i].helium.halfTime)
            )
            
            session.compartments[i].helium.pressure = ph
            
            session.compartments[i].ceiling = calculateCeilingPressure(
                Pn: pn,
                an: session.compartments[i].nitrogen.a,
                bn: session.compartments[i].nitrogen.b,
                Phe: ph,
                ahe: session.compartments[i].helium.a,
                bhe: session.compartments[i].helium.b,
                gf: session.gradientFactors.current
            )
            
            session.compartments[i].modificationDate = .now
        }
    }
}
