//
//  WatchToIOSConnector.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import Foundation
import WatchConnectivity

@Observable class WatchToiOSConnector: NSObject, WCSessionDelegate {
    
    var session: WCSession
    var lastMessageReceived: [String : Any]?
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
        switch activationState {
        case .activated:
            print("WATCH: Session activated successfully.")
        case .inactive:
            print("WATCH: Session is inactive.")
        case .notActivated:
            print("WATCH: Session is not activated")
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        lastMessageReceived = message
    }
    
    func sendMessageToiOS(message: [String: Any]) {
        if (session.isReachable) {
            session.sendMessage(message, replyHandler: nil) { error in
                print(error)
            }
        }
        else {
            print("Session is not reachable")
        }
    }
    
    func sendDataToiOS(jsonData: Data) {
        session.sendMessageData(jsonData, replyHandler: nil) { error in
            print(error)
        }
    }
}
