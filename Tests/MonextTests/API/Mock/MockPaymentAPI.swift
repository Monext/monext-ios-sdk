//
//  MockPaymentAPI.swift
//  Monext
//
//  Created by SDK Mobile on 24/07/2025.
//

import Foundation
@testable import Monext

final class MockPaymentAPI: PaymentAPIProtocol {
    
    func stateCurrent(sessionToken: String) async throws -> Monext.SessionState {
        throw NSError(domain: "Mock", code: -1)
    }
    
    func payment(sessionToken: String, params: Monext.PaymentRequest) async throws -> Monext.SessionState {
        throw NSError(domain: "Mock", code: -1)
    }
    
    func securePayment(sessionToken: String, params: Monext.SecuredPaymentRequest) async throws -> Monext.SessionState {
        throw NSError(domain: "Mock", code: -1)
    }
    
    func sdkPaymentRequest(sessionToken: String, params: Monext.AuthenticationResponse) async throws -> Monext.SessionState {
        throw NSError(domain: "Mock", code: -1)
    }
    
    func walletPayment(sessionToken: String, params: Monext.WalletPaymentRequest) async throws -> Monext.SessionState {
        throw NSError(domain: "Mock", code: -1)
    }
    
    func availableCardNetworks(sessionToken: String, params: Monext.AvailableCardNetworksRequest) async throws -> Monext.AvailableCardNetworksResponse {
        throw NSError(domain: "Mock", code: -1)
    }
    
    func fetchSchemes(sessionToken: String) async throws -> Monext.DirectoryServerSdkKeyListResponse {
        return DirectoryServerSdkKeyListResponse(directoryServerSdkKeyList: [
            RemoteScheme(
                scheme: "VISA",
                rid: "A000000003",
                publicKey: "mock-visa-public-key",
                rootPublicKey: "mock-visa-root-public-key"
            ),
            RemoteScheme(
                scheme: "MASTERCARD",
                rid: "A000000004",
                publicKey: "mock-mastercard-public-key",
                rootPublicKey: "mock-mastercard-root-public-key"
            ),
            RemoteScheme(
                scheme: "CB",
                rid: "A000000042",
                publicKey: "mock-cb-public-key",
                rootPublicKey: "mock-cb-root-public-key"
            ),
            RemoteScheme(
                scheme: "AMEX",
                rid: "A000000025",
                publicKey: "mock-amex-public-key",
                rootPublicKey: "mock-amex-root-public-key"
            )
        ])
    }
    
    func returnURLString(sessionToken: String) -> String {
        return "https://mock.url?token=\(sessionToken)"
    }
    
    func getEnvironment() -> Monext.MnxtEnvironment {
        return .sandbox
    }
}
