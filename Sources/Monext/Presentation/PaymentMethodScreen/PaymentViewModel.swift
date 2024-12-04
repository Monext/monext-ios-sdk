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
    
    func buildPaymentRequest(sessionToken: String, paymentMethodData data: PaymentMethodData) -> PaymentRequest {
        return PaymentRequest(
            cardCode: data.cardCode ?? "",
            merchantReturnUrl: paymentAPI.returnURLString(sessionToken: sessionToken),
            isEmbeddedRedirectionAllowed: true,
            paymentParams: .init(savePaymentData: saveCard),
            contractNumber: data.contractNumber ?? ""
        )
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
}
