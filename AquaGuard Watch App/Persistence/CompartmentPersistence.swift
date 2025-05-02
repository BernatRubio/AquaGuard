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
                compartmentEntity.nitrogenPressure = compartment.nitrogen.pressure
                compartmentEntity.heliumPressure = compartment.helium.pressure
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
