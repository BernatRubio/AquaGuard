//
//  TestDiveInstance.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import CoreData

extension DiveEntity {
    @discardableResult
    static func createTestInstance(in context: NSManagedObjectContext) -> DiveEntity {
        let dive = DiveEntity(context: context)
        
        // MARK: — Dive attributes
        dive.id                     = UUID().uuidString
        dive.startTime              = Date().addingTimeInterval(-3600)        // 1 hour ago
        dive.endTime                = Date()                                   // now
        dive.diveTime               = 60 * 60                                  // 1 hour in seconds
        dive.gfLow                  = 20.0
        dive.gfHigh                 = 85.0
        dive.heliumPercentage       = 0.0
        dive.nitrogenPercentage     = 0.79
        dive.respiratoryQuotient    = 0.85
        dive.surfacePressureUnit    = "bar"
        dive.surfacePressureValue   = 1.0
        
        // MARK: — Compartments
        for i in 1...3 {
            let comp = CompartmentEntity(context: context)
            comp.compartmentNumber   = Int16(i)
            comp.heliumPressure      = Double(i) * 0.1
            comp.nitrogenPressure    = Double(i) * 0.2
            comp.modificationDate    = Date()
            dive.addToCompartments(comp)
        }
        
        // MARK: — Deco-stops
        let stop1 = DecoStopEntity(context: context)
        stop1.endTime    = Date().addingTimeInterval(2.0)
        stop1.startTime  = Date()
        stop1.pressure   = 2.0
        dive.addToDecoStops(stop1)
        
        let stop2 = DecoStopEntity(context: context)
        stop2.endTime    = Date().addingTimeInterval(5.0)
        stop2.startTime  = Date()
        stop2.pressure   = 6.0
        dive.addToDecoStops(stop2)
        
        // MARK: — Measurements
        let interval: TimeInterval = 900  // 15 * 60
        var idx = 0
        for offset in stride(from: 0.0, to: dive.diveTime, by: interval) {
            let m = MeasurementEntity(context: context)
            // Set the absolute timestamp
            m.date             = dive.startTime?.addingTimeInterval(offset) ?? Date()
            // Example depth curve: ramp from 0 to 30m
            m.depthValue       = Double(idx) * (30.0 / ((dive.diveTime / interval) - 1))
            m.depthUnit        = "m"
            // Example pressure: ambient + depth/10
            m.pressureValue    = dive.surfacePressureValue + m.depthValue / 10.0
            m.pressureUnit     = dive.surfacePressureUnit ?? "bar"
            // Toggle submersion state just for demo (0 = down, 1 = up)
            m.submersionState  = Int16(idx % 2)
            
            dive.addToMeasurements(m)
            idx += 1
        }
        return dive
    }
}
