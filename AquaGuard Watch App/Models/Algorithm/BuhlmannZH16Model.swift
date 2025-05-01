//
//  BuhlmannZH16Model.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import Foundation

// Revisat i correcte segons TAUCHMEDIZIN
let ZHL16_N2: [TissueGasComponent] = [
    TissueGasComponent(halfTime: 5.0, a: 1.1696, b: 0.5578),
    TissueGasComponent(halfTime: 8.0, a: 1.0, b: 0.6514),
    TissueGasComponent(halfTime: 12.5, a: 0.8618, b: 0.7222),
    TissueGasComponent(halfTime: 18.5, a: 0.7562, b: 0.7825),
    TissueGasComponent(halfTime: 27.0, a: 0.62, b: 0.8126),
    TissueGasComponent(halfTime: 38.3, a: 0.5043, b: 0.8434),
    TissueGasComponent(halfTime: 54.3, a: 0.441, b: 0.8693),
    TissueGasComponent(halfTime: 77.0, a: 0.4, b: 0.891),
    TissueGasComponent(halfTime: 109.0, a: 0.375, b: 0.9092),
    TissueGasComponent(halfTime: 146.0, a: 0.35, b: 0.9222),
    TissueGasComponent(halfTime: 187.0, a: 0.3295, b: 0.9319),
    TissueGasComponent(halfTime: 239.0, a: 0.3065, b: 0.9403),
    TissueGasComponent(halfTime: 305.0, a: 0.2835, b: 0.9477),
    TissueGasComponent(halfTime: 390.0, a: 0.261, b: 0.9544),
    TissueGasComponent(halfTime: 498.0, a: 0.248, b: 0.9602),
    TissueGasComponent(halfTime: 635.0, a: 0.2327, b: 0.9653)
]

// Revisat i correcte segons TAUCHMEDIZIN
let ZHL16_He: [TissueGasComponent] = [
    TissueGasComponent(halfTime: 1.88, a: 1.6189, b: 0.477),
    TissueGasComponent(halfTime: 3.02, a: 1.383, b: 0.5747),
    TissueGasComponent(halfTime: 4.72, a: 1.1919, b: 0.6527),
    TissueGasComponent(halfTime: 6.99, a: 1.0458, b: 0.7223),
    TissueGasComponent(halfTime: 10.21, a: 0.922, b: 0.7582),
    TissueGasComponent(halfTime: 14.48, a: 0.8205, b: 0.7957),
    TissueGasComponent(halfTime: 20.53, a: 0.7305, b: 0.8279),
    TissueGasComponent(halfTime: 29.11, a: 0.6502, b: 0.8553),
    TissueGasComponent(halfTime: 41.20, a: 0.595, b: 0.8757),
    TissueGasComponent(halfTime: 55.19, a: 0.5545, b: 0.8903),
    TissueGasComponent(halfTime: 70.69, a: 0.5333, b: 0.8997),
    TissueGasComponent(halfTime: 90.34, a: 0.5189, b: 0.9073),
    TissueGasComponent(halfTime: 115.29, a: 0.5181, b: 0.9122),
    TissueGasComponent(halfTime: 147.42, a: 0.5176, b: 0.9171),
    TissueGasComponent(halfTime: 188.24, a: 0.5172, b: 0.9217),
    TissueGasComponent(halfTime: 240.03, a: 0.5119, b: 0.9267)
]

func calculateAlveolarPressure(Pamb: Double, Q: Double, RQ: Double) -> Double {
    guard RQ != 0.0 else { fatalError("RQ cannot be zero") }
    let vw = Pamb - 0.0627 + (1.0 - RQ) / RQ * 0.0534
    return ((vw * Q) * 10000).rounded() / 10000
}

func decayConstant(fromHalfTime halftime: Double) -> Double {
    guard halftime > 0.0 else { fatalError("halftime must be greater than zero") }
    return ((log(2) / halftime) * 10000).rounded() / 10000
}

func calculateGasRate(d0: Double, dt: Double, t: Double, Q: Double) -> Double {
    guard t > 0.0 else { fatalError("t must be greater than zero") }
    let dP = (dt - d0) / t
    return ((dP * Q) * 10000).rounded() / 10000
}

func schreinerEquation(Pi: Double, Palv: Double, t: Double, R: Double, k: Double) -> Double {
    guard k > 0.0 else { fatalError("k must be greater than zero") }
    let x1 = R * (t - 1.0 / k)
    let x2 = Palv - Pi - R / k
    let x3 = exp(-k * t)
    return ((Palv + x1 - x2 * x3) * 10000).rounded() / 10000
}

func calculateCeilingPressure(Pn: Double, an: Double, bn: Double, Phe: Double = 0.0, ahe: Double = 0.0, bhe: Double = 0.0, gf: Double = 1.0) -> Double {
    let P = Pn + Phe
    guard P > 0.0 else { fatalError("P must be greater than zero") }
    let a = (an * Pn + ahe * Phe) / P
    let b = (bn * Pn + bhe * Phe) / P
    let num = P - a * gf
    let den = gf / (b + 1.0 - gf)
    guard den != 0.0 else { fatalError("denominator can't be zero") }
    return ((num / den) * 10000).rounded() / 10000
}
