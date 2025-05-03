//
//  MeasurementEncodable.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

extension MeasurementEntity: Encodable {
  enum CodingKeys: String, CodingKey {
    case date, depthUnit, depthValue, pressureUnit, pressureValue, submersionState
  }
  public func encode(to encoder: Encoder) throws {
      var c = encoder.container(keyedBy: CodingKeys.self)
      
      // Attributes
      try c.encode(date,                    forKey: .date)
      try c.encode(depthUnit,               forKey: .depthUnit)
      try c.encode(depthValue,              forKey: .depthValue)
      try c.encode(pressureUnit,            forKey: .pressureUnit)
      try c.encode(pressureValue,           forKey: .pressureValue)
      try c.encode(submersionState,         forKey: .submersionState)
  }
}
