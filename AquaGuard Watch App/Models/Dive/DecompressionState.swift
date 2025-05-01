//
//  DecompressionState.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import Foundation

struct DecompressionState {
    var decoStops: [DecoStop]
    var currentStopDepth: Measurement<UnitLength>?
}
