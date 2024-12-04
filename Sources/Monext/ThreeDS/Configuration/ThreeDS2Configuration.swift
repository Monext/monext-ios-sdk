//
//  ThreeDS2Configuration.swift
//  Monext
//
//  Created by SDK Mobile on 16/07/2025.
//

import Foundation
import ThreeDS_SDK

struct ThreeDS2Configuration {
    static let apiKey = MonextConfig.NetecteraAPIKey
    static let messageVersion = "2.2.0"
    static let maxTimeout = 60
    static let defaultDeviceRenderingOptionsIF = "01"
    static let defaultDeviceRenderOptionsUI = "03"
    
    static func createConfigParameters(schemes: [Scheme]) throws -> ConfigParameters {
        let configBuilder = ConfigurationBuilder()
        try configBuilder.api(key: apiKey)
        
        for scheme in schemes {
            try configBuilder.add(scheme)
        }
        
        return configBuilder.configParameters()
    }
}
