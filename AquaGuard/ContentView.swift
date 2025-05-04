//
//  ContentView.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import SwiftUI

struct ContentView: View {
    @State var watchConnector = WatchConnector()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
