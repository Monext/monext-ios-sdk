//
//  DylibCheck.swift
//  Monext
//
//  Created by lucas bianciotto  on 29/09/2026.
//

import MachO

struct DylibCheck: SecurityCheck {

    private let suspiciousDylibs = [
        "MobileSubstrate",
        "SSLKillSwitch",
        "TweakInject",
        "FridaGadget",
        "frida",
        "cynject",
        "libhooker",
        "SubstrateLoader",
        "SubstrateInserter",
        "rocketbootstrap",
        "substitute"
    ]

    func check() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return containsSuspiciousImage(loadedImageNames())
        #endif
    }

    // Cherche les marqueurs de frameworks de hooking dans une liste d'images
    func containsSuspiciousImage(_ imageNames: [String]) -> Bool {
        imageNames.contains { name in
            let imageName = name.lowercased()
            return suspiciousDylibs.contains { imageName.contains($0.lowercased()) }
        }
    }

    // Toutes les images chargées dans le process courant
    private func loadedImageNames() -> [String] {
        (0..<_dyld_image_count()).compactMap { index in
            _dyld_get_image_name(index).map { String(cString: $0) }
        }
    }
}
