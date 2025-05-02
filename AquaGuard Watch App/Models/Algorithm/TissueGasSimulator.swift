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
        let oldPressure = session.currentPressure.converted(to: .bars).value
        guard let newPressure = measurement.pressure?.converted(to: .bars).value else { return }
        let segmentTime = (measurement.date.timeIntervalSince(session.currentTime) * 1000).rounded() / 1000 // Approx. 0.333 seconds if called 3 times per second
        guard segmentTime > 0 else { return }
        
        for i in 0..<ZHL16_N2.count {
            let nitrogenPressure = session.compartments[i].nitrogen.pressure
            let nitrogenPercentage = session.gasMix.nitrogenPercentage
            let respiratoryQuotient = config.respiratoryQuotient
            
            let pn = schreinerEquation(
                Pi: nitrogenPressure,
                Palv: calculateAlveolarPressure(Pamb: newPressure, Q: nitrogenPercentage, RQ: respiratoryQuotient),
                t: segmentTime,
                R: calculateGasRate(d0: oldPressure, dt: newPressure, t: segmentTime, Q: nitrogenPercentage),
                k: decayConstant(fromHalfTime: session.compartments[i].nitrogen.halfTime)
            )
            
            session.compartments[i].nitrogen.pressure = pn
            
            let heliumPressure = session.compartments[i].helium.pressure
            let heliumPercentage = session.gasMix.heliumPercentage
            
            let ph = schreinerEquation(
                Pi: heliumPressure,
                Palv: calculateAlveolarPressure(Pamb: newPressure, Q: heliumPercentage, RQ: respiratoryQuotient),
                t: segmentTime,
                R: calculateGasRate(d0: oldPressure, dt: newPressure, t: segmentTime, Q: heliumPercentage),
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
