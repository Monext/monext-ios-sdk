//
//  MonextEnvironment.swift
//  Monext
//
//  Created by Joshua Pierce on 10/03/2025.
//

import SwiftUI

/**
 The Monext environment that the SDK will use
 */
public enum MnxtEnvironment: Sendable {
    
    /// homologation-payment.payline.com
    case sandbox
    
    /// payment.payline.com
    case production
    
    /// A custom environment
    case custom(hostname: String)
    
    internal var host: String {
        switch self {
        case .sandbox: return "homologation-payment.payline.com"
        case .production: return "payment.payline.com"
        case let .custom(host): return host
        }
    }
    
    func isSandbox() -> Bool {
        switch self {
        case .sandbox, .custom:
            return true
        case .production:
            return false
        }
    }
}

extension MnxtEnvironment: Identifiable, Hashable {
    public var id: String { host }
}
