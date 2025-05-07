//
//  InertGasLoading.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//
import CoreMotion

struct TissueGasComponent {
    let halfTime: Double
    let a: Double
    let b: Double
    var pressure: Measurement<UnitPressure>
}
