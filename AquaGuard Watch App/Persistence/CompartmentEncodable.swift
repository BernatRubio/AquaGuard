//
//  CompartmentEncodable.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

extension CompartmentEntity: Encodable {
  enum CodingKeys: String, CodingKey {
    case compartmentNumber, nitrogenPressure, heliumPressure, modificationDate, dive
  }
  public func encode(to encoder: Encoder) throws {
      var c = encoder.container(keyedBy: CodingKeys.self)
      
      // Attributes
      try c.encode(compartmentNumber,        forKey: .compartmentNumber)
      try c.encode(nitrogenPressure,         forKey: .nitrogenPressure)
      try c.encode(heliumPressure,           forKey: .heliumPressure)
      try c.encode(modificationDate,         forKey: .modificationDate)
  }
}
