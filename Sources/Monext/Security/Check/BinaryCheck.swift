//
//  BinaryCheck.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import Foundation

struct BinaryCheck: SecurityCheck {
    
    private let jailbreakPaths = [
        "/Applications/Cydia.app",
        "/Applications/Sileo.app",
        "/Applications/Zebra.app",
        "/usr/sbin/sshd",
        "/usr/bin/ssh",
        "/bin/bash",
        "/bin/sh",
        "/etc/apt",
        "/private/var/lib/apt",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/var/checkra1n.dmg",
        "/var/jb"            // Jailbreaks rootless (Dopamine, palera1n)
    ]
    
    func check() -> Bool {
        // Sur simulateur on skip
        #if targetEnvironment(simulator)
        return false
        #else
        return checkKnownPaths() || checkSandboxViolation()
        #endif
    }
    
    private func checkKnownPaths() -> Bool {
        jailbreakPaths.contains { FileManager.default.fileExists(atPath: $0) }
    }
    
    // Tente d'écrire hors du sandbox — impossible sur device propre
    private func checkSandboxViolation() -> Bool {
        let testPath = "/private/jailbreak_test_\(UUID().uuidString)"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: testPath)
            return true // A pu écrire hors sandbox → jailbreaké
        } catch {
            return false
        }
    }
}
