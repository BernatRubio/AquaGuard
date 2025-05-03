//
//  DataListDivesView.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import SwiftUI
import CoreData

struct DataListDivesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var dives: FetchedResults<DiveEntity>
    
    var body: some View {
        NavigationView {
            List(dives, id: \.self) { dive in
                if let id = dive.id {
                    let diveTime = (dive.diveTime / 60).rounded().formatted()
                    NavigationLink("Id: \(id)\nDive Time: \(diveTime) min", destination: DataSingleDiveView(dive: dive))
                }
            }
        }
    }
}

#Preview {
    DataListDivesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
