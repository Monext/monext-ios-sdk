//
//  PaymentViewModel.swift
//  Monext
//
//  Created by Joshua Pierce on 04/12/2024.
//

import SwiftUI

@MainActor
class PaymentViewModel: ObservableObject {
    
    private let paymentAPI: PaymentAPIProtocol
    
    @Published var isLoading: Bool = false
    @Published var cvv: String = ""
    @Published var saveCard: Bool = false
    @Published var formValid: Bool = false
    @Published var alternativeFormData: [String: String] = [:]
    @Published var cardFormViewModel: CardFormViewModel?
    
    init(paymentAPI: PaymentAPIProtocol,
         isLoading: Bool = false,
         cvv: String = "",
         saveCard: Bool = false,
         formValid: Bool = false,
         cardFormViewModel: CardFormViewModel? = nil) {
        
        self.paymentAPI = paymentAPI
        self.isLoading = isLoading
        self.cvv = cvv
        self.saveCard = saveCard
        self.formValid = formValid
        self.cardFormViewModel = cardFormViewModel
    }
    
    enum PaymentRequestType {
        case standard(PaymentRequest)
        case secured(SecuredPaymentRequest)
    }
    
    func buildPaymentRequest(sessionToken: String, paymentMethodData data: PaymentMethodData) -> PaymentRequestType {
        if data.isSecured {
            
            let timezone = TimeZone.current
            let secondsDiff = timezone.secondsFromGMT()
            let minutesDiff = Double(secondsDiff) / 60.0
            let minutesDiffRounded = Int(minutesDiff.rounded(.down))
            
            let securedRequest = SecuredPaymentRequest(
                cardCode: data.cardCode ?? "",
                contractNumber: data.contractNumber ?? "",
                deviceInfo: DeviceInfo(
                    colorDepth: 32, // No native color depth API (Apple)
                    containerHeight: PaymentViewModel.getContainerHeight(),
                    containerWidth: PaymentViewModel.getContainerWidth(),
                    javaEnabled: false,
                    screenHeight: Int(UIScreen.main.bounds.height.rounded(.down)),
                    screenWidth: Int(UIScreen.main.bounds.width.rounded(.down)),
                    timeZoneOffset: minutesDiffRounded
                ),
                isEmbeddedRedirectionAllowed: true,
                merchantReturnUrl: paymentAPI.returnURLString(sessionToken: sessionToken),
                paymentParams: .init(
                    savePaymentData: saveCard,
                    customFields: [:] // Pas de champs personnalisés dans paymentParams
                ),
                securedPaymentParams: .init(
                    customFields: alternativeFormData // Les champs vont dans securedPaymentParams
                )
            )
            return .secured(securedRequest)
        } else {
            let standardRequest = PaymentRequest(
                cardCode: data.cardCode ?? "",
                merchantReturnUrl: paymentAPI.returnURLString(sessionToken: sessionToken),
                isEmbeddedRedirectionAllowed: true,
                paymentParams: .init(
                    savePaymentData: saveCard,
                    customFields: alternativeFormData // Les champs vont dans paymentParams
                ),
                contractNumber: data.contractNumber ?? ""
            )
            return .standard(standardRequest)
        }
    }
    
    func buildSecuredPaymentRequest(with threeDSManager: ThreeDS2Manager) async -> SecuredPaymentRequest? {
        await cardFormViewModel?.buildPaymentRequest(with: threeDSManager)
    }
    
    func buildWalletPaymentRequest(with threeDSProvider: ThreeDS2Manager?, sessionToken: String, wallet: Wallet) async -> WalletPaymentRequest {
        let securedPaymentParams: [String: String] = cvv.isEmpty ? [:] : ["CVV": cvv]
        
        let sdkContextData = await threeDSProvider?.generateSDKContextDataSync()
        
        return WalletPaymentRequest(
            cardCode: wallet.cardCode,
            index: wallet.index,
            isEmbeddedRedirectionAllowed: true,
            merchantReturnUrl: paymentAPI.returnURLString(sessionToken: sessionToken),
            paymentParams: PaymentParams(sdkContextData: sdkContextData),
            securedPaymentParams: securedPaymentParams
        )
    }
    
    public static func getContainerHeight() -> Double {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return Double(window.frame.height)
        }
        return Double(UIScreen.main.bounds.height)
    }

    public static func getContainerWidth() -> Double {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return Double(window.frame.width)
        }
        return Double(UIScreen.main.bounds.width)
    }
}
