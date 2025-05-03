//
//  DiveEncodable.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import Foundation
import CoreData

extension DiveEntity: Encodable {
  enum CodingKeys: String, CodingKey {
    case id, startTime, endTime, diveTime
    case gfLow, gfHigh, heliumPercentage, nitrogenPercentage, respiratoryQuotient
    case surfacePressureUnit, surfacePressureValue
    case compartments, decoStops, measurements
  }
  
  public func encode(to encoder: Encoder) throws {
    var c = encoder.container(keyedBy: CodingKeys.self)
    
    // Attributes
    try c.encode(id,                       forKey: .id)
    try c.encode(startTime,                forKey: .startTime)
    try c.encode(endTime,                  forKey: .endTime)
    try c.encode(diveTime,                 forKey: .diveTime)
    try c.encode(gfLow,                    forKey: .gfLow)
    try c.encode(gfHigh,                   forKey: .gfHigh)
    try c.encode(heliumPercentage,         forKey: .heliumPercentage)
    try c.encode(nitrogenPercentage,       forKey: .nitrogenPercentage)
    try c.encode(respiratoryQuotient,      forKey: .respiratoryQuotient)
    try c.encode(surfacePressureUnit,      forKey: .surfacePressureUnit)
    try c.encode(surfacePressureValue,     forKey: .surfacePressureValue)
    
    // To-many relationships: just cast to Set and encode as Array
    let comps = (self.compartments as? Set<CompartmentEntity>) ?? []
    try c.encode(Array(comps),             forKey: .compartments)
    
    let stops = (self.decoStops as? Set<DecoStopEntity>) ?? []
    try c.encode(Array(stops),             forKey: .decoStops)
    
    let meas  = (self.measurements as? Set<MeasurementEntity>) ?? []
    try c.encode(Array(meas),              forKey: .measurements)
  }
}
