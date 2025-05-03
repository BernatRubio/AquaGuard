//
//  DataListMeasurementsView.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import SwiftUI
import CoreData

struct DataListMeasurementsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let dive: DiveEntity
    
    var body: some View {
        let measurements = (dive.measurements as? Set<MeasurementEntity> ?? [])
        let sorted = measurements.sorted { $0.date! < $1.date! }
        NavigationView {
            List(sorted, id: \.self) { measurement in
                let pressure = measurement.pressureValue.formatted()
                Text("Pressure: \(pressure) \(measurement.pressureUnit ?? "")")
            }
        }
    }
}

#Preview {
    let previewCtx = PersistenceController.preview.container.viewContext
    let dive = DiveEntity.createTestInstance(in: previewCtx)
    DataListMeasurementsView(dive: dive)
}
