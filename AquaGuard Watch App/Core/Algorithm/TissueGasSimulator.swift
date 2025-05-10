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
        let surfacePressure = session.surfacePressure.converted(to: .bars)
        let oldPressure = session.currentPressure.converted(to: .bars).value
        guard let newPressure = measurement.pressure?.converted(to: .bars).value else { return }
        let segmentTime = (measurement.date.timeIntervalSince(session.currentTime) * 1000).rounded() / 1000 // Approx. 0.333 seconds if called 3 times per second
        let segmentTimeInMinutes = segmentTime / 60
        guard segmentTimeInMinutes > 0 else { return }
        
        for i in 0..<ZHL16_N2.count {
            let nitrogenPressure = session.compartments[i].nitrogen.pressure.converted(to: .bars).value
            let nitrogenPercentage = session.gasMix.nitrogenPercentage
            let respiratoryQuotient = config.respiratoryQuotient
            
            let pn = schreinerEquation(
                Pi: nitrogenPressure,
                Palv: calculateAlveolarPressure(Pamb: newPressure, Q: nitrogenPercentage, RQ: respiratoryQuotient),
                t: segmentTimeInMinutes,
                R: calculateGasRate(d0: oldPressure, dt: newPressure, t: segmentTimeInMinutes, Q: nitrogenPercentage),
                k: decayConstant(fromHalfTime: session.compartments[i].nitrogen.halfTime)
            )
            
            session.compartments[i].nitrogen.pressure = .init(value: pn, unit: .bars)
            
            let heliumPressure = session.compartments[i].helium.pressure.converted(to: .bars).value
            let heliumPercentage = session.gasMix.heliumPercentage
            
            let ph = schreinerEquation(
                Pi: heliumPressure,
                Palv: calculateAlveolarPressure(Pamb: newPressure, Q: heliumPercentage, RQ: respiratoryQuotient),
                t: segmentTimeInMinutes,
                R: calculateGasRate(d0: oldPressure, dt: newPressure, t: segmentTimeInMinutes, Q: heliumPercentage),
                k: decayConstant(fromHalfTime: session.compartments[i].helium.halfTime)
            )
            
            session.compartments[i].helium.pressure = .init(value: ph, unit: .bars)
            
            session.compartments[i].gaugeCeiling = calculateCeilingGaugePressure(
                Pn: pn,
                an: session.compartments[i].nitrogen.a,
                bn: session.compartments[i].nitrogen.b,
                Phe: ph,
                ahe: session.compartments[i].helium.a,
                bhe: session.compartments[i].helium.b,
                gf: session.gradientFactors.current,
                surfacePressure: surfacePressure
            )
            
            session.compartments[i].modificationDate = .now
        }
    }
}
