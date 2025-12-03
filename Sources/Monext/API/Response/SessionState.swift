//
//  SessionState.swift
//  Monext
//
//  Created by Joshua Pierce on 08/11/2024.
//

import Foundation
import SwiftUI
import ThreeDS_SDK

struct SessionState: Decodable, Equatable {
    var token: String
    var type: String
    var automaticRedirectAtSessionsEnd: Bool?
    var cancelUrl: String?
    var creationDate: String?
    var info: SessionInfo?
    var isSandbox: Bool?
    var language: String?
    var pointOfSale: String?
    var pointOfSaleAddress: PointOfSaleAddress?
    var returnUrl: String?
    var fragmented: Bool?
    var stateSpecificData: StateSpecificData?
    var paymentMethodsList: PaymentMethodsList?
    var paymentRedirectNoResponse: PaymentRedirectNoResponse?
    var paymentOnholdPartner: PaymentOnholdPartner?
    var paymentSuccess: PaymentSuccess?
    var paymentFailure: PaymentFailure?
    var paymentSdkChallenge: PaymentSdkChallenge?
    var activeWaiting: ActiveWaiting?
}

struct SessionInfo: Decodable, Equatable {
    
    var amountSmallestUnit: Int64
    var buyerIp: String?
    var buyerMobilePhone: String?
    var currencyCode: String
    var currencyDigits: Int
    var formattedAmount: String
    var formattedOrderAmount: String
    var merchantCountry: String
    var orderAmountSmallestUnit: Int
    var orderDate: String
    var orderDeliveryMode: String?
    var orderDeliveryTime: String?
    var orderRef: String
    
    enum CodingKeys: String, CodingKey {
        case amountSmallestUnit = "PaylineAmountSmallestUnit"
        case buyerIp = "PaylineBuyerIp"
        case buyerMobilePhone = "PaylineBuyerMobilePhone"
        case currencyCode = "PaylineCurrencyCode"
        case currencyDigits = "PaylineCurrencyDigits"
        case formattedAmount = "PaylineFormattedAmount"
        case formattedOrderAmount = "PaylineFormattedOrderAmount"
        case merchantCountry = "PaylineMerchantCountry"
        case orderAmountSmallestUnit = "PaylineOrderAmountSmallestUnit"
        case orderDate = "PaylineOrderDate"
        case orderDeliveryMode = "PaylineOrderDeliveryMode"
        case orderDeliveryTime = "PaylineOrderDeliveryTime"
        case orderRef = "PaylineOrderRef"
    }
}

struct PointOfSaleAddress: Decodable, Equatable {
    let address1: String?
    let address2: String?
    let city: String?
    let zipCode: String?
}

struct StateSpecificData: Decodable, Equatable {
    var sdkChallengeData: SdkChallengeData?
}

struct PaymentSdkChallenge: Decodable, Equatable {
    var sdkChallengeData: SdkChallengeData
}

struct SdkChallengeData: Decodable, Equatable {
    var cardType: Int
    var threeDSServerTransID: String
    var threeDSVersion: String
    var authenticationType: String
    var transStatus: String? = nil
    var sdkTransID: String
    var dsTransID: String
    var acsTransID: String? = nil
    var acsRenderingType: String
    var acsReferenceNumber: String
    var acsSignedContent: String
    var acsOperatorID: String
    var acsChallengeMandated: String
    
    /// Crée un objet ChallengeParameters à partir des données SDK Challenge
    func toChallengeParameters() -> ChallengeParameters {
        ChallengeParameters(
            threeDSServerTransactionID: self.threeDSServerTransID,
            acsTransactionID: self.acsTransID ?? "",
            acsRefNumber: self.acsReferenceNumber,
            acsSignedContent: self.acsSignedContent
        )
    }
    
    /// Crée un objet AuthenticationResponse à partir des données SDK Challenge
    func toAuthenticationResponse() -> AuthenticationResponse {
        AuthenticationResponse(
            acsReferenceNumber: self.acsReferenceNumber,
            acsTransID: self.acsTransID,
            threeDSVersion: self.threeDSVersion,
            threeDSServerTransID: self.threeDSServerTransID,
            transStatus: self.transStatus
        )
    }
}

struct ActiveWaiting: Decodable, Equatable {
    let needActiveWaitingAction: Bool
    let message: CustomMessage?
    let cardCode: String?
    let contractNumber: String?
    let walletCardIndex: Int?
    let merchantReturnUrl: String?
}

struct PaymentMethodsList: Decodable, Equatable {
    
    var isOriginalCreditTransfer: Bool
    var needsDeviceFingerprint: Bool
    var paymentMethodsData: [PaymentMethodData]
    var scoringNeeded: Bool?
    var sensitiveInputContentMasked: Bool
    var shouldChangePaymentMethodPosition: Bool
    var wallets: [Wallet]
    
    enum CodingKeys: String, CodingKey {
        case isOriginalCreditTransfer
        case needsDeviceFingerprint
        case paymentMethodsData = "paymentMethods"
        case scoringNeeded
        case sensitiveInputContentMasked
        case shouldChangePaymentMethodPosition
        case wallets
    }
    
    var paymentMethods: [PaymentMethod] {
        var group = [PaymentMethod]()
        var cardsArray: [PaymentMethodData] = []
        for pm in paymentMethodsData {
            if pm.isCard {
                cardsArray.append(pm)
            } else {
                if let individual = PaymentMethod.forIndividualPaymentMethod(pm) {
                    group.append(individual)
                }
            }
        }
        if !cardsArray.isEmpty {
            group.insert(.cards(cardsArray), at: 0)
        }
        return group
    }
    
    var selectablePaymentMethods: [PaymentMethod] {
        paymentMethods.filter {
            switch $0 {
            case .applePay: return false
            default: return true
            }
        }
    }
}

// TODO: Any types need to be defined
struct PaymentMethodData: Decodable, Hashable {
    
    /**
     The payment method identifier.
     - Examples:
        - CB
        - VISA
        - PAYPAL
        - IDEAL
        - etc.
     */
    let cardCode: String?
    
//    let confirm: [Any]
    
    /// The contract identifier
    let contractNumber: String?
    
    let disabled: Bool?
    
    let hasForm: Bool?
    let form: PaymentMethodForm?
    
    let hasLogo: Bool?
    let logo: PaymentMethodLogo?
    
    let isIsolated: Bool?
    
    /**
     Various options for diplaying fields of the card form
     
     - SeeAlso: `KnownOptionsKey`
     */
    let options: [String]?
    
    let paymentMethodAction: Int?
    
//    let paymentParamsToBeControlled: [Any]
    
    let additionalData: AdditionalData
    
    let shouldBeInTopPosition: Bool?
    
    let state: String?
    
    var isCard: Bool {
        [
            PaymentMethodCardCode.cb.rawValue,
            PaymentMethodCardCode.mcvisa.rawValue,
            PaymentMethodCardCode.amex.rawValue
//            MAESTRO
//            AMEX-REC BILLING
//            JCB
//            BCMC
//            BC/MC
//            DINERS_DISCOVER
//            TOTALGR
        ]
        .contains(cardCode)
    }
    
    var isSecured: Bool {
         return form?.formFields?.contains { $0.secured == true } ?? false
     }
    
    static let cardGroup: [PaymentMethodData] = {
        PreviewData.paymentMethodData.filter { $0.isCard }
    }()
    
    enum KnownOptionsKey: String, CaseIterable {
        case cvv = "CVV"
        case alternativeNetwork = "ALT_NETWORK"
        case expirationDate = "EXPI_DATE"
        case cardHolder = "HOLDER"
        case saveCard = "SAVE_PAYMENT_DATA"
    }
}

struct PaymentMethodForm: Decodable, Hashable {
    var displayButton: Bool
    var description: String?
    var buttonText: String?
    var formFields: [PaymentMethodFormField]?
    var formType: String?
}
struct PaymentMethodFormField: Decodable, Hashable, Identifiable {
    var content: String?
    var formFieldType: String?
    var formDisplayFieldType: String?
    var validationErrorMessage: String?
    var placeholder: String?
    var inputType: String?
    var fieldIcon: String?
    var key: String?
    var label: String?
    var required: Bool?
    var requiredErrorMessage: String?
    var formInputFieldType: String?
    var secured: Bool?
    var disabled: Bool?
    var validation: PaymentMethodFieldValidation?

    var index: Int? = nil

    // Identifiable: privilégie `key` si présente (et supposée unique), sinon l'index.
    // En dernier recours, on génère un UUID.
    var id: String {
        if let k = key, !k.isEmpty { return k }
        if let i = index { return "index_\(i)" }
        return UUID().uuidString
    }
}

struct PaymentMethodFieldValidation: Decodable, Hashable {
    var pattern: String?
}

struct PaymentMethodLogo: Decodable, Hashable {
    let width: Int
    let height: Int
    let url: String
    let alt: String
    let title: String
}

struct AdditionalData: Decodable, Hashable {
    
    var merchantCapabilities: [String]? = nil
    var networks: [String]? = nil
    var applePayMerchantId: String? = nil
    var applePayMerchantName: String? = nil
    var savePaymentDataChecked: Bool? = nil
    var email: String? = nil
    var date: String? = nil
    var holder: String? = nil
    var pan: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case merchantCapabilities = "MERCHANT_CAPABILITIES"
        case networks = "NETWORKS"
        case applePayMerchantId = "APPLE_PAY_MERCHANT_ID"
        case applePayMerchantName = "APPLE_PAY_MERCHANT_NAME"
        case savePaymentDataChecked = "SAVE_PAYMENT_DATA_CHECKED"
        case email = "EMAIL"
        case date = "DATE"
        case holder = "HOLDER"
        case pan = "PAN"
    }
}

struct Wallet: Decodable, Hashable {
    
    let additionalData: AdditionalData
    let cardCode: String
    let cardType: String
    let confirm: [String]
    let customLogoRatio: Int
    let expiredMore6Months: Bool
    let hasCustomLogo: Bool
    let hasCustomLogoBase64: Bool
    let hasCustomLogoUrl: Bool
    let hasSpecificDisplay: Bool
    let index: Int
    let isDefault: Bool
    let isExpired: Bool
    let isPmAPI: Bool
    let options: [String]?
}

struct PaymentRedirectNoResponse: Decodable, Equatable {
    let cardCode: String
    let contractNumber: String
    let redirectionData: RedirectionData
    let walletCardIndex: Int?
}

struct RedirectionData: Decodable, Equatable {
    let hasPartnerLogo: Bool
    let iframeEmbeddable: Bool
    let iframeHeight: Int
    let iframeWidth: Int
    let isCompletionMethod: Bool
    let requestType: String
    let requestUrl: String
    let timeoutInMs: Int
    let requestFields: [String: String]?
}

struct PaymentOnholdPartner: Decodable, Equatable {
    let message: CustomMessage?
    let selectedCardCode: String
    let selectedContractNumber: String
}

struct CustomMessage: Decodable, Equatable {
    let type: String
    let localizedMessage: String
    let displayIcon: Bool
}

struct PaymentSuccess: Decodable, Equatable {
    let displayTicket: Bool
    let fragmented: Bool
    let paymentCard: String?
    let selectedCardCode: String
    let selectedContractNumber: String
    let ticket: [Ticket]?
}

struct Ticket: Decodable, Hashable, Equatable {
    
    let interline: Bool
    let key: String?
    let style: String?
    let t: Int
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case interline = "i"
        case key = "k"
        case style = "s"
        case t
        case value = "v"
    }
}

struct PaymentFailure: Decodable, Equatable {
    let message: Message
    let selectedCardCode: String
    let selectedContractNumber: String
}

struct Message: Decodable, Equatable {
    let displayIcon: Bool
    let localizedMessage: String
    let type: String
}
