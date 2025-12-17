//
//  PaymentAPIProtocol.swift
//  Monext
//
//  Created by SDK Mobile on 24/07/2025.
//

import Foundation

protocol PaymentAPIProtocol: Sendable {
    func stateCurrent(sessionToken: String) async throws -> SessionState
    func isDone(sessionToken: String, cardCode: String) async throws -> Bool
    func payment(sessionToken: String, params: PaymentRequest) async throws -> SessionState
    func securePayment(sessionToken: String, params: SecuredPaymentRequest) async throws -> SessionState
    func sdkPaymentRequest(sessionToken: String, params: AuthenticationResponse) async throws -> SessionState
    func walletPayment(sessionToken: String, params: WalletPaymentRequest) async throws -> SessionState
    func availableCardNetworks(sessionToken: String, params: AvailableCardNetworksRequest) async throws -> AvailableCardNetworksResponse
    func fetchSchemes(sessionToken: String) async throws -> DirectoryServerSdkKeyListResponse
    func sendLog(message: String, level: String, url: String?, token: String?, loggerName: String) async throws
    func sendError(message: String, url: String?, token: String?, loggerName: String)
    func returnURLString(sessionToken: String) -> String
    func getEnvironment() -> MnxtEnvironment
}
