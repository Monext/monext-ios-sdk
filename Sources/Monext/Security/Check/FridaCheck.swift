//
//  FridaCheck.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import Foundation
import Network

// Les librairies Frida injectées sont couvertes par DylibCheck, ici on ne teste que le serveur
struct FridaCheck: SecurityCheck {
    
    static let fridaDefaultPort: NWEndpoint.Port = 27042
    
    var host: NWEndpoint.Host = "127.0.0.1"
    var port: NWEndpoint.Port = Self.fridaDefaultPort
    var timeout: TimeInterval = 0.3
    
    func check() -> Bool {
        isPortOpen()
    }
    
    // Identique à Android — port 27042
    private func isPortOpen() -> Bool {
        let outcome = ConnectionOutcome()
        let semaphore = DispatchSemaphore(value: 0)
        
        let connection = NWConnection(host: host, port: port, using: .tcp)
        connection.stateUpdateHandler = { state in
            // On n'attend que les états finaux : .setup / .preparing arrivent avant la connexion
            switch state {
            case .ready:
                outcome.setOpen()
                semaphore.signal()
            case .failed, .waiting, .cancelled:
                semaphore.signal()
            default:
                break
            }
        }
        connection.start(queue: .global())
        _ = semaphore.wait(timeout: .now() + timeout)
        connection.cancel()
        return outcome.isOpen
    }
}

private final class ConnectionOutcome: @unchecked Sendable {
    private let lock = NSLock()
    private var open = false
    
    var isOpen: Bool {
        lock.lock()
        defer { lock.unlock() }
        return open
    }
    
    func setOpen() {
        lock.lock()
        open = true
        lock.unlock()
    }
}
