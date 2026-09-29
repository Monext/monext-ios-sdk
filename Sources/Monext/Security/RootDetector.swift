//
//  RootDetector.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import Foundation

protocol CompromisedDeviceDetecting: Sendable {
    func isCompromised() -> Bool
}

public final class RootDetector: CompromisedDeviceDetecting, @unchecked Sendable {
    
    #if DEBUG
    public static let shared = RootDetector(checks: [])
    #else
    public static let shared = RootDetector(checks: [
        BinaryCheck(),
        PackageCheck(),
        FridaCheck(),
        DylibCheck(),        // Vérifie les dylibs injectées
        SymlinkCheck()       // /etc → /private/etc etc.
    ])
    #endif
    
    private let checks: [SecurityCheck]
    private let cacheTTL: TimeInterval
    private let now: @Sendable () -> Date
    
    // Protège le cache : le préchargement tourne en arrière-plan pendant que l'UI peut interroger le détecteur
    private let lock = NSLock()
    private var isCompromisedCache: Bool?
    private var lastCheckTime: Date?
    
    init(checks: [SecurityCheck], cacheTTL: TimeInterval = 30, now: @escaping @Sendable () -> Date = { Date() }) {
        self.checks = checks
        self.cacheTTL = cacheTTL
        self.now = now
    }
    
    public func isCompromised() -> Bool {
        if let cached = cachedResult() {
            return cached
        }
        
        // Checks exécutés hors du lock : PackageCheck peut attendre le main thread
        let result = checks.contains { $0.check() }
        
        lock.lock()
        isCompromisedCache = result
        lastCheckTime = now()
        lock.unlock()
        return result
    }
    
    private func cachedResult() -> Bool? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let cached = isCompromisedCache,
              let lastCheck = lastCheckTime,
              now().timeIntervalSince(lastCheck) < cacheTTL else {
            return nil
        }
        return cached
    }
}
