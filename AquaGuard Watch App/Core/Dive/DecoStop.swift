//
//  DecoStop.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import Foundation

struct DecoStop {
    let startTime: Date = .now
    var endTime: Date = .now
    let gaugePressure: Measurement<UnitPressure>
    
    mutating func setEndTime() {
        endTime = .now
    }
}
