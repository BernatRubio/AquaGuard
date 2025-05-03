//
//  DataSingleDiveView.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import SwiftUI

struct DataSingleDiveView: View {
    let dive: DiveEntity
    var body: some View {
        let id = dive.id ?? "No ID"
        let startTime = dive.startTime?.formatted(date: .omitted, time: .shortened) ?? "No Start Time"
        let endTime = dive.endTime?.formatted(date: .omitted, time: .shortened) ?? "No End Time"
        NavigationView {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    VStack {
                        Text("Start Time: \(startTime)").foregroundStyle(.black)
                        Text("End Time: \(endTime)").foregroundStyle(.black)
                        
                        NavigationLink("Measurements", destination: DataListMeasurementsView(dive: dive))
                            .foregroundStyle(.blue)
                    }
                    .padding()
            }
        }
    }
}

#Preview {
    let previewCtx = PersistenceController.preview.container.viewContext
    let dive = DiveEntity.createTestInstance(in: previewCtx)
    DataSingleDiveView(dive: dive)
}
