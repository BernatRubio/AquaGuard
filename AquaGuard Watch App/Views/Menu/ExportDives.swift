//
//  ExportDives.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 4/5/25.
//

import SwiftUI

struct ExportDives: View {
    @FetchRequest(entity: DiveEntity.entity(), sortDescriptors: []) var dives: FetchedResults<DiveEntity>
    @State var watchToiOSConnector = WatchToiOSConnector()
    var body: some View {
        Button("Export Dives") {
            export()
        }
    }
    
    func export() {
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(Array(dives))
        watchToiOSConnector.sendDataToiOS(jsonData: jsonData)
    }
}
