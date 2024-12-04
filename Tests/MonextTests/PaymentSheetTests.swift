//
//  PaymentSheetTests.swift
//  Monext
//
//  Created by SDK Mobile on 01/08/2025.
//

import XCTest
import SwiftUI
@testable import Monext

@MainActor
class PaymentSheetTests: BaseAPITestCase {
    
    private let mockToken = "1cEtH2D3ogZsaJ4PE1531746023359858"
    
    override func setUp() {
        super.setUp()
        Task {
            await MockURLProtocol.clearHandler()
        }
        setupAPI()
    }

    override func tearDown() {
        Task {
            await MockURLProtocol.clearHandler()
        }
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createMockThreeDSManager() -> ThreeDS2Manager {
        return ThreeDS2Manager(
            paymentAPI: api,
            uiConfig: .init()
        )
    }
    
    /// Creates a PaymentSheet instance with default configuration for testing
    /// - Parameters:
    ///   - token: Session token to use
    ///   - sessionStateStore: The session state store environment object
    /// - Returns: Configured PaymentSheet view
    private func createPaymentSheet(
        token: String = "1cEtH2D3ogZsaJ4PE1531746023359858",
        sessionStateStore: SessionStateStore
    ) -> some View {
        return PaymentSheet(
            sessionToken: token,
            isPresented: .constant(true),
            onResult: { _ in },
            threeDSManager: createMockThreeDSManager(),
            challengeExecuted: .constant(false),
            onChallengeRequired: nil
        )
        .environmentObject(sessionStateStore)
    }
    
    /// Sets up mock response and updates session state
    /// - Parameters:
    ///   - token: Session token
    ///   - jsonFileName: Name of the JSON mock file
    ///   - sessionStateStore: Session state store to update
    private func setupMockAndUpdateSession(
        token: String,
        jsonFileName: String,
        sessionStateStore: SessionStateStore
    ) async throws {
        clearMockResponses()
        
        // Setup the mock response using withCheckedThrowingContinuation to handle MainActor properly
        try await withCheckedThrowingContinuation { continuation in
            Task {
                await setupMockResponse(
                    for: token,
                    endpoint: "state/current",
                    jsonFileName: jsonFileName
                )
                continuation.resume()
            }
        }
        
        // Update the session state
        try await sessionStateStore.updateSessionState(token: token)
    }
    
    /// Verifies that the session state has expected values
    /// - Parameters:
    ///   - sessionStateStore: The session state store to verify
    ///   - expectedToken: Expected token value
    ///   - expectedType: Expected session type
    private func verifySessionState(
        _ sessionStateStore: SessionStateStore,
        expectedToken: String,
        expectedType: String
    ) {
        XCTAssertNotNil(sessionStateStore.sessionState, "Session state should not be nil")
        XCTAssertEqual(sessionStateStore.sessionState?.token, expectedToken, "Session token should match expected value")
        XCTAssertEqual(sessionStateStore.sessionState?.type, expectedType, "Session type should match expected value")
    }
    
    // MARK: - Test Cases
    
    /// Test that PaymentSheet displays loading screen when session state is not available
    func testPaymentSheetDisplaysLoadingScreenWhenSessionStateIsNil() async throws {
        // Given: A fresh session state store without any loaded state
        let sessionStateStore = createSessionStateStore()
        
        let paymentSheet = createPaymentSheet(
            token: mockToken,
            sessionStateStore: sessionStateStore
        )
        
        // When: PaymentSheet is rendered
        let view = try paymentSheet.inspect()
        
        // Then: Session state should be nil and LoadingScreen should be displayed
        XCTAssertNil(sessionStateStore.sessionState, "Initial session state should be nil")
        XCTAssertNoThrow(try view.find(LoadingScreen.self), "LoadingScreen should be displayed when session state is nil")
    }
    
    /// Test that PaymentSheet displays payment method screen when session type is PAYMENT_METHODS_LIST
    func testPaymentSheetDisplaysPaymentMethodScreenWhenSessionTypeIsPaymentMethodsList() async throws {
        // Given: A session state store with payment methods list response
        let sessionStateStore = createSessionStateStore()
        
        try await setupMockAndUpdateSession(
            token: mockToken,
            jsonFileName: "PaymentMethodList",
            sessionStateStore: sessionStateStore
        )
        
        let paymentSheet = createPaymentSheet(
            token: mockToken,
            sessionStateStore: sessionStateStore
        )
        
        // When: PaymentSheet is rendered with payment methods list state
        let view = try paymentSheet.inspect()
        
        // Then: Session state should be configured correctly and PaymentMethodScreen should be displayed
        verifySessionState(
            sessionStateStore,
            expectedToken: mockToken,
            expectedType: "PAYMENT_METHODS_LIST"
        )
        XCTAssertNoThrow(try view.find(PaymentMethodScreen.self), "PaymentMethodScreen should be displayed for PAYMENT_METHODS_LIST type")
    }
    
    /// Test that PaymentSheet displays redirection screen when session type is PAYMENT_REDIRECT_NO_RESPONSE
    func testPaymentSheetDisplaysRedirectionScreenWhenSessionTypeIsRedirectNoResponse() async throws {
        // Given: A session state store with redirect no response state
        let sessionStateStore = createSessionStateStore()
        
        try await setupMockAndUpdateSession(
            token: mockToken,
            jsonFileName: "PaymentRedirectNoResponse",
            sessionStateStore: sessionStateStore
        )
        
        let paymentSheet = createPaymentSheet(
            token: mockToken,
            sessionStateStore: sessionStateStore
        )
        
        // When: PaymentSheet is rendered with redirect no response state
        let view = try paymentSheet.inspect()
        
        // Then: Session state should be configured correctly and RedirectionScreen should be displayed
        verifySessionState(
            sessionStateStore,
            expectedToken: mockToken,
            expectedType: "PAYMENT_REDIRECT_NO_RESPONSE"
        )
        XCTAssertNoThrow(try view.find(RedirectionScreen.self), "RedirectionScreen should be displayed for PAYMENT_REDIRECT_NO_RESPONSE type")
    }
    
    /// Test that PaymentSheet displays loading screen when session type is SDK_CHALLENGE
    func testPaymentSheetDisplaysLoadingScreenWhenSessionTypeIsSdkChallenge() async throws {
        // Given: A session state store with SDK challenge state
        let sessionStateStore = createSessionStateStore()
        
        try await setupMockAndUpdateSession(
            token: mockToken,
            jsonFileName: "SdkChallenge",
            sessionStateStore: sessionStateStore
        )
        
        let paymentSheet = createPaymentSheet(
            token: mockToken,
            sessionStateStore: sessionStateStore
        )
        
        // When: PaymentSheet is rendered with SDK challenge state
        let view = try paymentSheet.inspect()
        
        // Then: Session state should be configured correctly and LoadingScreen should be displayed
        verifySessionState(
            sessionStateStore,
            expectedToken: mockToken,
            expectedType: "SDK_CHALLENGE"
        )
        XCTAssertNoThrow(try view.find(LoadingScreen.self), "LoadingScreen should be displayed for SDK_CHALLENGE type")
    }
    
    /// Test that PaymentSheet displays success screen when session type is PAYMENT_SUCCESS
    func testPaymentSheetDisplaysSuccessScreenWhenSessionTypeIsPaymentSuccess() async throws {
        // Given: A session state store with payment success state
        let sessionStateStore = createSessionStateStore()
        
        try await setupMockAndUpdateSession(
            token: mockToken,
            jsonFileName: "PaymentSuccess",
            sessionStateStore: sessionStateStore
        )
        
        let paymentSheet = createPaymentSheet(
            token: mockToken,
            sessionStateStore: sessionStateStore
        )
        
        // When: PaymentSheet is rendered with payment success state
        let view = try paymentSheet.inspect()
        
        // Then: Session state should be configured correctly and SuccessScreen should be displayed
        verifySessionState(
            sessionStateStore,
            expectedToken: mockToken,
            expectedType: "PAYMENT_SUCCESS"
        )
        XCTAssertNoThrow(try view.find(SuccessScreen.self), "SuccessScreen should be displayed for PAYMENT_SUCCESS type")
    }
    
    /// Test that PaymentSheet displays success screen when session type is PAYMENT_ONHOLD_PARTNER
    func testPaymentSheetDisplaysSuccessScreenWhenSessionTypeIsPending() async throws {
        // Given: A session state store with payment success state
        let sessionStateStore = createSessionStateStore()
        
        try await setupMockAndUpdateSession(
            token: mockToken,
            jsonFileName: "PaymentPending",
            sessionStateStore: sessionStateStore
        )
        
        let paymentSheet = createPaymentSheet(
            token: mockToken,
            sessionStateStore: sessionStateStore
        )
        
        // When: PaymentSheet is rendered with payment success state
        let view = try paymentSheet.inspect()
        
        // Then: Session state should be configured correctly and SuccessScreen should be displayed
        verifySessionState(
            sessionStateStore,
            expectedToken: mockToken,
            expectedType: "PAYMENT_ONHOLD_PARTNER"
        )
        XCTAssertNoThrow(try view.find(PendingScreen.self), "SuccessScreen should be displayed for PAYMENT_ONHOLD_PARTNER type")
    }
    
    /// Test that PaymentSheet displays failure screen when session type is PAYMENT_FAILURE
    func testPaymentSheetDisplaysFailureScreenWhenSessionTypeIsPaymentFailure() async throws {
        // Given: A session state store with payment failure state
        let sessionStateStore = createSessionStateStore()
        
        try await setupMockAndUpdateSession(
            token: mockToken,
            jsonFileName: "PaymentFailure",
            sessionStateStore: sessionStateStore
        )
        
        let paymentSheet = createPaymentSheet(
            token: mockToken,
            sessionStateStore: sessionStateStore
        )
        
        // When: PaymentSheet is rendered with payment failure state
        let view = try paymentSheet.inspect()
        
        // Then: Session state should be configured correctly and FailureScreen should be displayed
        verifySessionState(
            sessionStateStore,
            expectedToken: mockToken,
            expectedType: "PAYMENT_FAILURE"
        )
        XCTAssertNoThrow(try view.find(FailureScreen.self), "FailureScreen should be displayed for PAYMENT_FAILURE type")
    }
    
    /// Test that PaymentSheet displays token expired screen when session type is TOKEN_EXPIRED
    func testPaymentSheetDisplaysTokenExpiredScreenWhenSessionTypeIsTokenExpired() async throws {
        // Given: A session state store with token expired state
        let sessionStateStore = createSessionStateStore()
        
        try await setupMockAndUpdateSession(
            token: mockToken,
            jsonFileName: "TokenExpired",
            sessionStateStore: sessionStateStore
        )
        
        let paymentSheet = createPaymentSheet(
            token: mockToken,
            sessionStateStore: sessionStateStore
        )
        
        // When: PaymentSheet is rendered with token expired state
        let view = try paymentSheet.inspect()
        
        // Then: Session state should be configured correctly and TokenExpiredScreen should be displayed
        verifySessionState(
            sessionStateStore,
            expectedToken: mockToken,
            expectedType: "TOKEN_EXPIRED"
        )
        XCTAssertNoThrow(try view.find(TokenExpiredScreen.self), "TokenExpiredScreen should be displayed for TOKEN_EXPIRED type")
    }
}
