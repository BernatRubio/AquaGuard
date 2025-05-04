//
//  AquaGuardApp.swift
//  AquaGuard Watch App
//
//  Created by Bernat Rubió on 1/5/25.
//

import SwiftUI

@main
struct AquaGuard_Watch_AppApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
