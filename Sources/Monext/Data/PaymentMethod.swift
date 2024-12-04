//
//  PaymentMethod.swift
//  Monext
//
//  Created by Joshua Pierce on 04/12/2024.
//

import SwiftUI

enum PaymentMethod: Equatable, Sendable, Hashable {
    
    case cards([PaymentMethodData])
    case applePay(PaymentMethodData)
    case alternativePaymentMethod(PaymentMethodData)
    
    static func forIndividualPaymentMethod(_ pm: PaymentMethodData) -> PaymentMethod? {
        switch pm.cardCode {
        case PaymentMethodCardCode.cb.rawValue: return nil
        case PaymentMethodCardCode.mcvisa.rawValue: return nil
        case PaymentMethodCardCode.amex.rawValue: return nil
        case PaymentMethodCardCode.applePay.rawValue: return .applePay(pm)
        default:
            if pm.hasForm == true {
                return .alternativePaymentMethod(pm)
            }
            return nil
        }
    }
    
    var data: PaymentMethodData? {
        switch self {
        case .cards: return nil
        case let .applePay(data): return data
        case let .alternativePaymentMethod(data): return data
        }
    }
}

enum PaymentMethodCardCode: String {
    case cb = "CB"
    case mcvisa = "MCVISA"
    case amex = "AMEX"
    case applePay = "APPLE_PAY"
}
