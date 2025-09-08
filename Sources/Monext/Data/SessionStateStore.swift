//
//  SessionStateStore.swift
//  Monext
//
//  Created by Joshua Pierce on 09/12/2024.
//

import SwiftUI

@MainActor
final class SessionStateStore: ObservableObject {
    
    let env: MnxtEnvironment
    let appearance: Appearance
    let config: MnxtSDKConfiguration
    let applePayConfiguration: ApplePayConfiguration
    
    private let paymentAPI: PaymentAPIProtocol
    
    @Published var sessionState: SessionState?
    
    init(environment: MnxtEnvironment, sessionState: SessionState? = nil, appearance: Appearance, config: MnxtSDKConfiguration, applePayConfiguration: ApplePayConfiguration) {
        self.env = environment
        self.sessionState = sessionState
        self.appearance = appearance
        self.config = config
        self.applePayConfiguration = applePayConfiguration
        
        self.paymentAPI = PaymentAPI(config: config, environment: environment)
    }
    
    /// Initializer for testing - allows injecting a mock PaymentAPI
    init(
        paymentAPI: PaymentAPIProtocol,
        appearance: Appearance,
        config: MnxtSDKConfiguration = MnxtSDKConfiguration(),
        applePayConfiguration: ApplePayConfiguration = ApplePayConfiguration(),
        sessionState: SessionState? = nil
    ) {
        self.paymentAPI = paymentAPI
        self.appearance = appearance
        self.config = config
        self.applePayConfiguration = applePayConfiguration
        self.sessionState = sessionState
        
        // Extract environment from the API if possible, otherwise default to sandbox
        self.env = paymentAPI.getEnvironment()
    }
    
    func updateSessionState(token: String) async throws {
        let sState = try await paymentAPI.stateCurrent(sessionToken: token)
        animateSessionStateChange(sState)
    }
    
    func isDone() async throws {
        guard let token = sessionState?.token,
              let cardCode = sessionState?.activeWaiting?.cardCode else {
            return
        }
        let isDone = try await paymentAPI.isDone(sessionToken: token, cardCode: cardCode)
        if isDone {
            try await self.updateSessionState(token: token)
        } else {
            try await Task.sleep(for: .seconds(3))
            try await self.isDone()
        }
        
        return;
    }
    
    func makeWalletPayment(params: WalletPaymentRequest) async throws {
        guard let token = sessionState?.token else { return }
        let sState = try await paymentAPI.walletPayment(sessionToken: token, params: params)
        animateSessionStateChange(sState)
    }
    
    func makePayment(params: PaymentRequest) async throws {
        guard let token = sessionState?.token else { return }
        let sState = try await paymentAPI.payment(sessionToken: token, params: params)
        animateSessionStateChange(sState)
    }
    
    func makeApplePayPayment(params: PaymentRequest) async throws -> SessionState? {
        guard let token = sessionState?.token else { return nil }
        return try await paymentAPI.payment(sessionToken: token, params: params)
    }
    
    func makeSecuredPayment(params: SecuredPaymentRequest) async throws {
        guard let token = sessionState?.token else { return }
        let sState = try await paymentAPI.securePayment(sessionToken: token, params: params)
        animateSessionStateChange(sState)
    }
    
    func makeSdkPaymentRequest(params: AuthenticationResponse) async throws {
        guard let token = sessionState?.token else { return }
        let sState = try await paymentAPI.sdkPaymentRequest(sessionToken: token, params: params)
        animateSessionStateChange(sState)
    }
    
    private func animateSessionStateChange(_ sState: SessionState) {
        withAnimation {
            self.sessionState = sState
        }
    }
    
    func getPaymentAPI() -> PaymentAPIProtocol {
        return paymentAPI
    }
}

enum SessionType: String {
    case paymentMethods = "PAYMENT_METHODS_LIST"
    case redirection = "PAYMENT_REDIRECT_NO_RESPONSE"
    case pending = "PAYMENT_ONHOLD_PARTNER"
    case success = "PAYMENT_SUCCESS"
    case sdkChallenge = "SDK_CHALLENGE"
    case activeWaiting = "ACTIVE_WAITING"
    case failure = "PAYMENT_FAILURE"
    case canceled = "PAYMENT_CANCELED"
    case tokenExpired = "TOKEN_EXPIRED"
}
