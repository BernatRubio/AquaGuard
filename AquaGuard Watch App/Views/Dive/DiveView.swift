//
//  DiveView.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import SwiftUI


struct DiveView: View {
    @State var submersionManager = SubmersionManager.sharedInstance
    var body: some View {
        if submersionManager.diveSession != nil {
            GeneralTabView(manager: submersionManager)
                .navigationBarBackButtonHidden()
        }
        
        else {
            Text("Submerge to start a dive!")
        }
    }
}

#Preview {
    let session = DiveSession.previewSession()
    DiveView()
}

struct GeneralTabView: View {
    @State var manager: SubmersionManager
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                // Main info stack
                VStack(alignment: .leading, spacing: 12) {
                    
                    if let dive = manager.diveSession {
                        // Depth
                        DepthSubview(currentDepth: dive.currentDepth)
                        
                        // Dive time
                        DiveTimeSubview(diveTime: dive.diveTime)
                        
                        // Deco stop
                        DecoStopSubview(currentStopDepth: dive.decoState.currentStopDepth)
                        
                        // Temperature
                        TemperatureSubview(currentWaterTemperature: dive.currentWaterTemperature)
                    }
                }
                .foregroundColor(.white)
                .padding(16)
                .ignoresSafeArea(edges: .top)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.4))
    }
}

struct DepthSubview: View {
    let currentDepth: Measurement<UnitLength>
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(String(format: "%.1f", getDepth()))
                .font(.system(size: 48, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("m DEPTH")
                    .font(.caption)
            }
        }
    }
    
    private func getDepth() -> Double {
        return currentDepth.converted(to: .meters).value
    }
}

struct DiveTimeSubview: View {
    let diveTime: TimeInterval
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(formattedTime(from: diveTime))
                .font(.system(size: 32, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("DIVE TIME")
                    .font(.caption)
            }
        }
    }
    
    // Helper function to format elapsed time
    private func formattedTime(from time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct DecoStopSubview: View {
    let currentStopDepth: Measurement<UnitLength>
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(String(format: "%.0f", getDecoStop()))
                .font(.system(size: 32, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("m DECO STOP")
                    .font(.caption)
            }
        }
    }
    
    private func getDecoStop() -> Double {
        let decoStop = currentStopDepth.converted(to: .meters).value
        return decoStop
    }
}

struct TemperatureSubview: View {
    let currentWaterTemperature: Measurement<UnitTemperature>
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            let temperature = currentWaterTemperature
            Text(String(format: "%.0f", temperature.value))
                .font(.system(size: 32, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(temperature.unit.symbol) WATER")
                    .font(.caption)
            }
        }
    }
}
