//
//  Measurement+Persistence.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 2/5/25.
//

import CoreMotion
import CoreData

extension CMWaterSubmersionMeasurement {
    func saveMeasurementToCoreData(manager: SubmersionManager) {
        let context = PersistenceController.shared.container.viewContext
        let measurementEntity = MeasurementEntity(context: context)
        measurementEntity.date = self.date
        
        if let pressure = self.pressure?.converted(to: .bars) {
            measurementEntity.pressureValue = pressure.value
            measurementEntity.pressureUnit = pressure.unit.symbol
        }
        
        if let depth = self.depth?.converted(to: .meters) {
            measurementEntity.depthValue = depth.value
            measurementEntity.depthUnit = depth.unit.symbol
        }
        
        let submersionState = self.submersionState.rawValue
        measurementEntity.submersionState = Int16(submersionState)
        
        guard let diveSession = manager.diveSession else {
            return
        }
        measurementEntity.dive = diveSession.diveEntity
        
        if manager.cooldown <= 1 {
            PersistenceController.save()
            manager.cooldown = 180
        }
        else {
            manager.cooldown -= 1
        }
    }
}
