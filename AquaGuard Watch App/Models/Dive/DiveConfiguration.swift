//
//  DiveConfiguration.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import Foundation

struct DiveConfiguration {
    private let defaults = UserDefaults.standard

    var respiratoryQuotient: Double {
    let rq = defaults.double(forKey: "respiratoryQuotient")
    return rq != 0.0 ? rq : 1.0
    }

    var gfLow: Double {
    let low = defaults.double(forKey: "gradientFactorLow")
    return low != 0.0 ? low : 0.3
    }

    var gfHigh: Double {
    let high = defaults.double(forKey: "gradientFactorHigh")
    return high != 0.0 ? high : 0.8
    }
    
    var nitrogenPercentage: Double = 0.79
    
    var heliumPercentage: Double {
        let percentage = 1.0 - nitrogenPercentage
        return percentage
    }
}
