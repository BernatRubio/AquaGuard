//
//  MainView.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 4/5/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        TabView {
            StartDiveView()
            DataListDivesView()
            ExportDives()
        }
        .tabViewStyle(.carousel)
    }
}

#Preview {
}
