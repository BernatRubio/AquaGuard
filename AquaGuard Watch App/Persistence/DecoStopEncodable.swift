//
//  DecoStopEncodable.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

extension DecoStopEntity: Encodable {
  enum CodingKeys: String, CodingKey {
    case startTime, endTime, pressure
  }
  public func encode(to encoder: Encoder) throws {
      var c = encoder.container(keyedBy: CodingKeys.self)
      
      // Attributes
      try c.encode(startTime,        forKey: .startTime)
      try c.encode(endTime,          forKey: .endTime)
      try c.encode(pressure,         forKey: .pressure)
  }
}
