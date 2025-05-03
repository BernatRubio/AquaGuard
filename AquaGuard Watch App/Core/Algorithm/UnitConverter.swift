//
//  UnitConverter.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 2/5/25.
//

struct UnitConverter {
    static func barToMeterSeaWater(_ bar: Double) -> Double {
        return (((bar * 10) * 10).rounded()) / 10 // This rounding is acceptable and a common practice
    }
    
    static func barToFootSeaWater(_ bar: Double) -> Double {
        return (((bar * 33) * 10).rounded()) / 10 // This rounding is acceptable and a common practice
    }
}
