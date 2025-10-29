//
//  MockTransaction.swift
//  Monext
//
//  Created by SDK Mobile on 24/07/2025.
//

import Foundation
import UIKit
import ThreeDS_SDK

class MockTransaction: NSObject, Transaction {
    func getAuthenticationRequestParameters() throws -> ThreeDS_SDK.AuthenticationRequestParameters {
        return try AuthenticationRequestParameters(
             sdkTransactionId: "mock-transaction-id",
             deviceData: "mock-device-data",
             sdkEphemeralPublicKey: "mock-ephemeral-key",
             sdkAppId: "mock-app-id",
             sdkReferenceNumber: "mock-reference-number",
             messageVersion: "2.1.0"
         )
    }

    func doChallenge(challengeParameters: ThreeDS_SDK.ChallengeParameters, challengeStatusReceiver: any ThreeDS_SDK.ChallengeStatusReceiver, timeOut: Int, inViewController: UIViewController) throws {
        // Simule le challenge
    }

    func getProgressView() throws -> any ThreeDS_SDK.ProgressDialog {
        return MockProgressDialog()
    }

    func useBridgingExtension(version: ThreeDS_SDK.BridgingExtensionVersion) {
        // Simule l'activation de l'extension
    }

    func close() throws {
        // Nettoyage fictif
    }
}
