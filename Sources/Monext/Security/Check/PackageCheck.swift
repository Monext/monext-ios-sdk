//
//  PackageCheck.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

struct PackageCheck: SecurityCheck {
    
    // canOpenURL ne répond true que si l'app hôte déclare ces schemes dans LSApplicationQueriesSchemes
    private let jailbreakURLSchemes = [
        "cydia://",
        "sileo://",
        "zbra://",          // Zebra
        "filza://",         // Filza File Manager
        "activator://"      // Activator (Substrate)
    ]
    
    private let substratePaths = [
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/usr/lib/libsubstitute.dylib",    // Substitute (unc0ver)
        "/usr/lib/substrate",
        "/usr/lib/TweakInject.dylib"        // Dopamine / Ellekit
    ]
    
    func check() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return checkJailbreakApps() || checkCydiaSubstrate()
        #endif
    }
    
    // Tente d'ouvrir les URL schemes des apps jailbreak
    private func checkJailbreakApps() -> Bool {
        #if canImport(UIKit)
        let urls = jailbreakURLSchemes.compactMap(URL.init(string:))
        let canOpen: @Sendable () -> Bool = {
            MainActor.assumeIsolated {
                urls.contains { UIApplication.shared.canOpenURL($0) }
            }
        }
        return Thread.isMainThread ? canOpen() : DispatchQueue.main.sync(execute: canOpen)
        #else
        return false
        #endif
    }
    
    // Vérifie la présence de MobileSubstrate (Cydia Substrate / Substitute)
    private func checkCydiaSubstrate() -> Bool {
        substratePaths.contains { FileManager.default.fileExists(atPath: $0) }
    }
}
