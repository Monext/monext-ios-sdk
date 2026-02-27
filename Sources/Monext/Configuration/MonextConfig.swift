//
//  MonextConfig.swift
//  Monext
//
//  Created by SDK Mobile on 29/08/2025.
//

import Foundation

public struct MonextConfig {
    private static func loadPlist() -> [String: Any]? {
            guard let url = Bundle.module.url(forResource: "AppMetadata", withExtension: "plist"),
                  let data = try? Data(contentsOf: url),
                  let plist = try? PropertyListSerialization
                                .propertyList(from: data, options: [], format: nil),
                  let dict = plist as? [String: Any] else {
                return nil
            }
            return dict
        }
    
    // MARK: - Sensitive (embarquée dans le binaire via build plugin)

     /// Clé API Netcetera pour le 3DS SDK.
     /// Générée à la compilation depuis .env.local ou les variables d'environnement CI.
     /// Non visible dans le bundle distribué.
     public static var NetecteraAPIKey: String {
         APIConfig.netecteraAPIKey
     }

    
    
}
