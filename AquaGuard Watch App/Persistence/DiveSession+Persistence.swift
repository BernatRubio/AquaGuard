//
//  DiveSession+Persistence.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 2/5/25.
//

import CoreData

extension DiveSession {
    func saveDiveSessionToCoreData() {
        diveEntity.id = self.id
        diveEntity.startTime = self.startTime
        diveEntity.endTime = self.currentTime
        diveEntity.diveTime = self.diveTime
        diveEntity.surfacePressureValue = self.surfacePressure.converted(to: .bars).value
        diveEntity.surfacePressureUnit = self.surfacePressure.converted(to: .bars).unit.symbol
        
        diveEntity.nitrogenPercentage = self.gasMix.nitrogenPercentage
        diveEntity.heliumPercentage = self.gasMix.heliumPercentage
        diveEntity.respiratoryQuotient = self.respiratoryQuotient
        diveEntity.gfHigh = self.gradientFactors.high
        diveEntity.gfLow = self.gradientFactors.low
        
        // Store decoStops
        let context = PersistenceController.shared.container.viewContext
        for decoStop in self.decoState.decoStops {
            let decoStopEntity = DecoStopEntity(context: context)
            decoStopEntity.dive = diveEntity
            decoStopEntity.startTime = decoStop.startTime
            decoStopEntity.endTime = decoStop.endTime
            decoStopEntity.gaugePressure = decoStop.gaugePressure.value
        }
        
        CompartmentPersistence.persistCompartments(in: context, for: self, mustSave: true)
        
        PersistenceController.save()
    }
}
