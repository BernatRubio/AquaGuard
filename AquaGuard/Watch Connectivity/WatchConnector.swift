//
//  WatchConnector.swift
//  AquaGuard
//
//  Created by Bernat Rubió on 1/5/25.
//

import Foundation
import WatchConnectivity

@Observable class WatchConnector: NSObject, WCSessionDelegate {
    
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
            print("iOS: Session activated successfully.")
        case .inactive:
            print("iOS: Session is inactive.")
        case .notActivated:
            print("iOS: Session is not activated.")
        @unknown default:
            fatalError()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        lastMessageReceived = message
        UserDefaults.standard.set(message, forKey: "lastMessageReceived") // Faig això per comprovar que encara que l'App de l'iPhone no està oberta, si la sessió està activada vol dir que pot llegir els missatges que el rellotge li envia.
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        if let jsonString = String(data: messageData, encoding: .utf8) {
            print(jsonString)
        }
        else {
            print("Couldn’t decode data as UTF-8 JSON")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func sendMessageToWatch(message: [String : Any]) {
        if (session.isReachable) {
            session.sendMessage(message, replyHandler: nil)
        }
        else {
            print("Watch is not reachable")
        }
    }
}
