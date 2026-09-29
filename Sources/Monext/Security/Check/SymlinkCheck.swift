//
//  SymlinkCheck.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import Foundation

struct SymlinkCheck: SecurityCheck {

    // Sur un device propre ces liens pointent vers /private/... (cibles relatives : "private/etc")
    // Sur un device jailbreaké ils peuvent être redirigés
    private let expectedSymlinks = [
        "/etc": "/private/etc",
        "/var": "/private/var",
        "/tmp": "/private/var/tmp"
    ]

    // Chemins qui ne devraient JAMAIS être accessibles en lecture
    // sur un device non jailbreaké
    private let restrictedPaths = [
        "/private/var/stash",
        "/private/var/db/stash",
        "/private/var/mobile/Library/SBSettings/Themes",
        "/Library/MobileSubstrate",
        "/private/var/lib/apt",
        "/private/var/lib/dpkg"
    ]

    func check() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return checkSymlinks() || checkRestrictedPaths()
        #endif
    }

    // Une destination est suspecte si elle ne correspond pas à la cible attendue
    func isUnexpectedDestination(_ destination: String, for path: String) -> Bool {
        guard let expected = expectedSymlinks[path] else { return false }
        var normalized = destination.hasPrefix("/") ? destination : "/" + destination
        while normalized.count > 1 && normalized.hasSuffix("/") {
            normalized.removeLast()
        }
        return normalized != expected && normalized != path
    }

    private func checkSymlinks() -> Bool {
        expectedSymlinks.keys.contains { path in
            guard let destination = try? FileManager.default.destinationOfSymbolicLink(atPath: path) else {
                return false
            }
            return isUnexpectedDestination(destination, for: path)
        }
    }

    private func checkRestrictedPaths() -> Bool {
        restrictedPaths.contains { FileManager.default.fileExists(atPath: $0) }
    }
}
