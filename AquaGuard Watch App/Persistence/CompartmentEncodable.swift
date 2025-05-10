//
//  CompartmentEncodable.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

extension CompartmentEntity: Encodable {
  enum CodingKeys: String, CodingKey {
    case compartmentNumber, nitrogenPressureValue, nitrogenPressureUnit, heliumPressureValue, heliumPressureUnit, modificationDate, dive
  }
  public func encode(to encoder: Encoder) throws {
      var c = encoder.container(keyedBy: CodingKeys.self)
      
      // Attributes
      try c.encode(compartmentNumber,        forKey: .compartmentNumber)
      try c.encode(nitrogenPressureValue,         forKey: .nitrogenPressureValue)
      try c.encode(nitrogenPressureUnit,         forKey: .nitrogenPressureUnit)
      try c.encode(heliumPressureValue,           forKey: .heliumPressureValue)
      try c.encode(heliumPressureUnit,           forKey: .heliumPressureUnit)
      try c.encode(modificationDate,         forKey: .modificationDate)
  }
}
