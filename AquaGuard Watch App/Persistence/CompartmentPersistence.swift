//
//  CompartmentPersistence.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 2/5/25.
//

import CoreData

struct CompartmentPersistence {
    static var compartmentSaveCooldown: Int = 180
    
    static func persistCompartments(in context: NSManagedObjectContext, for session: DiveSession, mustSave: Bool = false) {
        if compartmentSaveCooldown <= 1 || mustSave {
            for compartment in session.compartments {
                let compartmentEntity = CompartmentEntity(context: context)
                compartmentEntity.compartmentNumber = Int16(compartment.compartmentNumber)
                let nitrogenPressure = compartment.nitrogen.pressure.converted(to: .bars)
                let heliumPressure = compartment.helium.pressure.converted(to: .bars)
                compartmentEntity.nitrogenPressureValue = nitrogenPressure.value
                compartmentEntity.nitrogenPressureUnit = nitrogenPressure.unit.symbol
                compartmentEntity.heliumPressureValue = heliumPressure.value
                compartmentEntity.heliumPressureUnit = heliumPressure.unit.symbol
                compartmentEntity.modificationDate = compartment.modificationDate
                compartmentEntity.dive = session.diveEntity
            }
            compartmentSaveCooldown = 180
        }
        else {
            compartmentSaveCooldown -= 1
        }
    }
}
