//
//  StartDiveView.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 4/5/25.
//

import SwiftUI

struct StartDiveView: View {
    @State private var navigate = false
    var body: some View {
        NavigationStack {
            Button("Start dive") {
                navigate = true
            }.font(.title).padding()
            .navigationDestination(isPresented: $navigate) {
                DiveView()
            }
        }
    }
}

#Preview {
}
