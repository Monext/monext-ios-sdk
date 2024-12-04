//
//  WalletPaymentRequest.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

struct WalletPaymentRequest: Encodable {
    let cardCode: String
    let index: Int
    let isEmbeddedRedirectionAllowed: Bool
    let merchantReturnUrl: String
    let paymentParams: PaymentParams
    let securedPaymentParams: [String: String]?
}
