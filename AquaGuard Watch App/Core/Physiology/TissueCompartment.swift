//
//  TissueCompartment.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import Foundation

struct TissueCompartment {
    let compartmentNumber: Int
    var nitrogen: TissueGasComponent
    var helium: TissueGasComponent
    var gaugeCeiling: Measurement<UnitPressure>
    var modificationDate: Date
}
