//
//  DiveView.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 3/5/25.
//

import SwiftUI


struct DiveView: View {
    let session: DiveSession?
    var body: some View {
        if session != nil {
            GeneralTabView(session: session)
        }
        
        else {
            Text("Submerge to start a dive!")
        }
    }
}

#Preview {
    let session = DiveSession.previewSession()
    DiveView(session: session)
}

struct GeneralTabView: View {
    @AppStorage("units") var units: String = "metric"
    let session: DiveSession?
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                // Main info stack
                VStack(alignment: .leading, spacing: 12) {
                    
                    if let dive = session {
                        // Depth
                        DepthSubview(diveSession: dive, units: units)
                        
                        // Dive time
                        DiveTimeSubview(diveTime: dive.diveTime)
                        
                        // Deco stop
                        DecoStopSubview(diveSession: dive, units: units)
                    }
                
//
//                    // Temperature
//                    Text(String(format: "%.0f°", getTemperature()))
//                        .font(.system(size: 48, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.trailing, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.4))
    }
    
    private func getTemperature() -> Double { #warning("TODO!")
        return 0.0
    }
}

struct DepthSubview: View {
    let diveSession: DiveSession
    let units: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(String(format: "%.0f", getDepth()))
                .font(.system(size: 48, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("m")
                    .font(.caption)
                Text("DEPTH")
                    .font(.caption2)
            }
        }
    }
    
    private func getDepth() -> Double {
        return diveSession.currentDepth.converted(to: .meters).value
    }
}

struct DiveTimeSubview: View {
    let diveTime: TimeInterval
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(formattedTime(from: diveTime))
                .font(.system(size: 32, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("DIVE")
                    .font(.caption)
                Text("TIME")
                    .font(.caption2)
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
    let diveSession: DiveSession
    let units: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(String(format: "%.0f", getDecoStop()))
                .font(.system(size: 32, weight: .bold))
            VStack(alignment: .leading, spacing: 2) {
                Text("DECO")
                    .font(.caption)
                Text("STOP")
                    .font(.caption2)
            }
        }
    }
    
    private func getDecoStop() -> Double {
        let decoStop = diveSession.decoState.currentStopDepth.converted(to: .meters).value
        return decoStop
    }
}
