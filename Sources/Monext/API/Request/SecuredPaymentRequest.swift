//
//  SecuredPaymentRequest.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//
import Foundation

struct PaymentRequest: Encodable, Equatable {
    let cardCode: String
    let merchantReturnUrl: String
    let isEmbeddedRedirectionAllowed: Bool
    let paymentParams: PaymentParams
    let contractNumber: String
}

struct SecuredPaymentRequest: Encodable, Equatable {
    let cardCode: String
    let contractNumber: String
    let deviceInfo: DeviceInfo
    let isEmbeddedRedirectionAllowed: Bool
    let merchantReturnUrl: String
    let paymentParams: PaymentParams
    let securedPaymentParams: SecuredPaymentParams
}

struct PaymentParams: Encodable, Equatable {
    var network: String = ""
    var expirationDate: String = ""
    var savePaymentData: Bool = false
    var holderName: String = ""
    var applePayToken: ApplePayToken? = nil
    var sdkContextData: SDKContextData? = nil
    var customFields: [String: String] = [:] // ← Ajout pour les champs dynamiques

    enum CodingKeys: String, CodingKey {
        case network = "NETWORK"
        case expirationDate = "EXPI_DATE"
        case savePaymentData = "SAVE_PAYMENT_DATA"
        case holderName = "HOLDER"
        case applePayToken = "APPLE_PAY_TOKEN"
        case sdkContextData = "SDK_CONTEXT_DATA"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encoder les champs fixes
        try container.encode(network, forKey: .network)
        try container.encode(expirationDate, forKey: .expirationDate)
        try container.encode(savePaymentData, forKey: .savePaymentData)
        try container.encode(holderName, forKey: .holderName)
        try container.encodeIfPresent(applePayToken, forKey: .applePayToken)

        if let sdkContextData = sdkContextData {
            let jsonData = try JSONEncoder().encode(sdkContextData)
            let jsonString = String(data: jsonData, encoding: .utf8)
            try container.encode(jsonString, forKey: .sdkContextData)
        }
        
        // Encoder les champs dynamiques directement dans le container principal
        var dynamicContainer = encoder.container(keyedBy: DynamicCodingKey.self)
        for (key, value) in customFields {
            let dynamicKey = DynamicCodingKey(stringValue: key)!
            try dynamicContainer.encode(value, forKey: dynamicKey)
        }
    }
}

// Helper pour les clés dynamiques
struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
// MARK: - Apple Pay structures
struct ApplePayToken: Encodable, Equatable {
    let paymentData: ApplePaymentData
    let transactionIdentifier: String
    let paymentMethod: ApplePaymentMethod
}

struct ApplePaymentData: Codable, Equatable {
    let data: String
    let signature: String
    let header: ApplePaymentDataHeader
    let version: String
}

struct ApplePaymentDataHeader: Codable, Equatable {
    let ephemeralPublicKey: String
    let publicKeyHash: String
    let transactionId: String
}

struct ApplePaymentMethod: Encodable, Equatable {
    let displayName: String
    let type: String
    let network: String
}

struct SecuredPaymentParams: Encodable, Equatable {
    
    var pan: String?
    var cvv: String?
    var customFields: [String: String] = [:] // ← Ajout pour les champs dynamiques sécurisés
    
    enum CodingKeys: String, CodingKey {
        case pan = "PAN"
        case cvv = "CVV"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encoder les champs fixes
        try container.encodeIfPresent(pan, forKey: .pan)
        try container.encodeIfPresent(cvv, forKey: .cvv)
        
        // Encoder les champs dynamiques directement dans le container principal
        var dynamicContainer = encoder.container(keyedBy: DynamicCodingKey.self)
        for (key, value) in customFields {
            let dynamicKey = DynamicCodingKey(stringValue: key)!
            try dynamicContainer.encode(value, forKey: dynamicKey)
        }
    }
}

struct DeviceInfo: Encodable, Equatable {
    let colorDepth: Int
    let containerHeight: Double
    let containerWidth: Double
    let javaEnabled: Bool
    let screenHeight: Int
    let screenWidth: Int
    let timeZoneOffset: Int
}
