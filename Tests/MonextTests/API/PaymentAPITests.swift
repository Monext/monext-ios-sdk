//
//  PaymentAPITests.swift
//  Monext
//
//  Created by SDK Mobile on 30/04/2025.
//

import Foundation
import XCTest

@testable import Monext

class PaymentAPITests: BaseAPITestCase {
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        setupAPI() // Use real PaymentAPI with mocked HTTP responses
    }
    
    // MARK: - State Tests
    
    /// Tests the state/current API endpoint to verify it returns a PAYMENT_METHODS_LIST state
    /// when called with a valid session token.
    func testStateCurrentReturnsPaymentMethodsList() async throws {
        // Given
        let token = "1cEtH2D3ogZsaJ4PE1531746023359858"
        
        await setupMockResponse(
            for: token,
            endpoint: "state/current",
            jsonFileName: "PaymentMethodList"
        )
        
        // When
        let result = try await api.stateCurrent(sessionToken: token)
        
        // Then
        XCTAssertEqual(token, result.token)
        XCTAssertEqual("PAYMENT_METHODS_LIST", result.type)
    }
    
    // MARK: - Payment Tests
    
    /// Tests the payment API endpoint to verify it processes a PayPal payment successfully
    /// and returns a PAYMENT_SUCCESS state with the correct token.
    func testPaymentWithPayPalReturnsSuccess() async throws {
        // Given
        let token = "1cEtH2D3ogZsaJ4PE1531746023359858"
        
        await setupMockResponse(
            for: token,
            endpoint: "paymentRequest",
            jsonFileName: "PaymentSuccess"
        )
        
        let params = PaymentRequest(
            cardCode: "PAYPAL",
            merchantReturnUrl: "https://homologation-payment.payline.com/v2?token=\(token)",
            isEmbeddedRedirectionAllowed: true,
            paymentParams: PaymentParams(
                network: "",
                expirationDate: "",
                savePaymentData: false,
                holderName: "",
                applePayToken: nil
            ),
            contractNumber: "PAYPAL_SDK_MLD"
        )
        
        // When
        let result = try await api.payment(sessionToken: token, params: params)
        
        // Then
        XCTAssertEqual(token, result.token)
        XCTAssertEqual("PAYMENT_SUCCESS", result.type)
    }
    
    /// Tests the secure payment API endpoint to verify it processes a CB card payment successfully
    /// with 3DS authentication data and returns a PAYMENT_SUCCESS state.
    func testSecurePaymentWithCBCardReturnsSuccess() async throws {
        // Given
        let token = "1cEtH2D3ogZsaJ4PE1531746023359858"
        
        await setupMockResponse(
            for: token,
            endpoint: "securedPaymentRequest",
            jsonFileName: "PaymentSuccess"
        )
        
        let params = SecuredPaymentRequest(
            cardCode: "CB",
            contractNumber: "CB_SDK_MLD",
            deviceInfo: Monext.DeviceInfo(
                colorDepth: 32,
                containerHeight: 498.467,
                containerWidth: 750,
                javaEnabled: false,
                screenHeight: 852,
                screenWidth: 393,
                timeZoneOffset: 120
            ),
            isEmbeddedRedirectionAllowed: true,
            merchantReturnUrl: "https://homologation-payment.payline.com/v2?token=1ok7AK2ML6JgYJVMI1521746021774476",
            paymentParams: Monext.PaymentParams(
                network: "1",
                expirationDate: "1230",
                savePaymentData: false,
                holderName: "",
                applePayToken: nil
            ),
            securedPaymentParams: Monext.SecuredPaymentParams(
                pan: Optional("4970105151515140"),
                cvv: Optional("123")
            )
        )
        
        // When
        let result = try await api.securePayment(sessionToken: token, params: params)
        
        // Then
        XCTAssertEqual(token, result.token)
        XCTAssertEqual("PAYMENT_SUCCESS", result.type)
    }
    
    /// Tests the SDK payment request API endpoint to verify it processes a 3DS authentication response
    /// and completes the payment successfully, returning a SDK_CHALLENGE state.
    func testSecurePaymentWithCBCardReturnsSdkChallenge() async throws {
        // Given
        let token = "1cEtH2D3ogZsaJ4PE1531746023359858"
        
        await setupMockResponse(
            for: token,
            endpoint: "securedPaymentRequest",
            jsonFileName: "SdkChallenge"
        )
        
        let params = SecuredPaymentRequest(
            cardCode: "CB",
            contractNumber: "CB_SDK_MLD",
            deviceInfo: Monext.DeviceInfo(
                colorDepth: 32,
                containerHeight: 498.467,
                containerWidth: 750,
                javaEnabled: false,
                screenHeight: 852,
                screenWidth: 393,
                timeZoneOffset: 120
            ),
            isEmbeddedRedirectionAllowed: true,
            merchantReturnUrl: "https://homologation-payment.payline.com/v2?token=1ok7AK2ML6JgYJVMI1521746021774476",
            paymentParams: Monext.PaymentParams(
                network: "1",
                expirationDate: "1230",
                savePaymentData: false,
                holderName: "",
                applePayToken: nil
            ),
            securedPaymentParams: Monext.SecuredPaymentParams(
                pan: Optional("4970105151515140"),
                cvv: Optional("123")
            )
        )
        
        // When
        let result = try await api.securePayment(sessionToken: token, params: params)
        
        // Then
        XCTAssertEqual(token, result.token)
        XCTAssertEqual("SDK_CHALLENGE", result.type)
        XCTAssertNotNil(result.stateSpecificData?.sdkChallengeData)
    }
    
    /// Tests the SDK payment request API endpoint to verify it processes a 3DS authentication response
    /// and completes the payment successfully, returning a PAYMENT_SUCCESS state.
    func testSdkPaymentRequestAfter3DSAuthenticationReturnsSuccess() async throws {
        // Given
        let token = "1cEtH2D3ogZsaJ4PE1531746023359858"
        
        await setupMockResponse(
            for: token,
            endpoint: "SdkPaymentRequest",
            jsonFileName: "PaymentSuccess"
        )
        
        let params = AuthenticationResponse(
            acsReferenceNumber: "3DS_LOA_ACS_MOMD_020301_00793",
            acsTransID: "80048496-f997-492d-a95d-d65253ec0806",
            threeDSVersion: "2.2.0",
            threeDSServerTransID: "Y",
            transStatus: "112e9b9a-e01f-548d-8000-00000052d0ca"
        )
        
        // When
        let result = try await api.sdkPaymentRequest(sessionToken: token, params: params)
        
        // Then
        XCTAssertEqual(token, result.token)
        XCTAssertEqual("PAYMENT_SUCCESS", result.type)
    }
    
    /// Tests the wallet payment API endpoint to verify it processes a payment using a stored card
    /// from the user's wallet and returns a PAYMENT_SUCCESS state.
    func testWalletPaymentWithStoredCardReturnsSuccess() async throws {
        // Given
        let token = "1cEtH2D3ogZsaJ4PE1531746023359858"
        
        await setupMockResponse(
            for: token,
            endpoint: "walletPaymentRequest",
            jsonFileName: "PaymentSuccess"
        )
        
        let params = WalletPaymentRequest(
            cardCode: "CB",
            index: 4, // Index of the stored card in the wallet
            isEmbeddedRedirectionAllowed: true,
            merchantReturnUrl: "https://homologation-payment.payline.com/v2?token=1O17gXrZHLPt93NUq1511746023550764",
            paymentParams: .init(),
            securedPaymentParams: Optional([:])
        )
        
        // When
        let result = try await api.walletPayment(sessionToken: token, params: params)
        
        // Then
        XCTAssertEqual(token, result.token)
        XCTAssertEqual("PAYMENT_SUCCESS", result.type)
    }
    
    // MARK: - Card Network Tests
    
    /// Tests the available card networks API endpoint to verify it returns the correct
    /// default and alternative networks for a given card number and contracts.
    func testAvailableCardNetworksReturnsCorrectNetworks() async throws {
        // Given
        let token = "1cEtH2D3ogZsaJ4PE1531746023359858"
        
        await setupMockResponse(
            for: token,
            endpoint: "availablecardnetworks",
            jsonFileName: "AvailableCardNetworks"
        )
        
        let params = AvailableCardNetworksRequest(
            cardNumber: "4970109000", // Partial card number for network detection
            handledContracts: [
                HandledContract(cardCode: "CB", contractNumber: "CB_SDK_MLD"),
                HandledContract(cardCode: "AMEX", contractNumber: "AMEX_SDK_MLD")
            ]
        )
        
        // When
        let result = try await api.availableCardNetworks(sessionToken: token, params: params)
        
        // Then
        XCTAssertEqual("CB", result.defaultNetwork)
        XCTAssertEqual("VISA", result.alternativeNetwork)
    }
    
    // MARK: - 3DS Schemes Tests
    
    /// Tests the fetch schemes API endpoint to verify it returns the complete list
    /// of directory server SDK keys for all supported card schemes (CB, VISA, MASTERCARD, AMEX, DINERS).
    func testFetchSchemesReturnsAllSupportedCardSchemes() async throws {
        // Given
        let token = "1cEtH2D3ogZsaJ4PE1531746023359858"
        
        await setupMockResponse(
            for: token,
            endpoint: "directoryServerSdkKeys",
            jsonFileName: "DirectoryServerSdkKeys"
        )
        
        // When
        let result = try await api.fetchSchemes(sessionToken: token)
        
        // Then
        // Verify we have all 5 expected schemes
        XCTAssertEqual(result.directoryServerSdkKeyList.count, 5)
        
        // Verify CB scheme details
        XCTAssertEqual(result.directoryServerSdkKeyList[0].scheme, "CB")
        XCTAssertEqual(result.directoryServerSdkKeyList[0].rid, "MOCK_RID_1")
        XCTAssertEqual(result.directoryServerSdkKeyList[0].publicKey, "MOCK_PUBLIC_KEY_1")
        XCTAssertEqual(result.directoryServerSdkKeyList[0].rootPublicKey, "MOCK_ROOT_PUBLIC_KEY_1")

        // Verify VISA scheme details
        XCTAssertEqual(result.directoryServerSdkKeyList[1].scheme, "VISA")
        XCTAssertEqual(result.directoryServerSdkKeyList[1].rid, "MOCK_RID_2")
        XCTAssertEqual(result.directoryServerSdkKeyList[1].publicKey, "MOCK_PUBLIC_KEY_2")
        XCTAssertEqual(result.directoryServerSdkKeyList[1].rootPublicKey, "MOCK_ROOT_PUBLIC_KEY_2")

        // Verify MASTERCARD scheme details
        XCTAssertEqual(result.directoryServerSdkKeyList[2].scheme, "MASTERCARD")
        XCTAssertEqual(result.directoryServerSdkKeyList[2].rid, "MOCK_RID_3")
        XCTAssertEqual(result.directoryServerSdkKeyList[2].publicKey, "MOCK_PUBLIC_KEY_3")
        XCTAssertEqual(result.directoryServerSdkKeyList[2].rootPublicKey, "MOCK_ROOT_PUBLIC_KEY_3")

        // Verify AMEX scheme details
        XCTAssertEqual(result.directoryServerSdkKeyList[3].scheme, "AMEX")
        XCTAssertEqual(result.directoryServerSdkKeyList[3].rid, "MOCK_RID_4")
        XCTAssertEqual(result.directoryServerSdkKeyList[3].publicKey, "MOCK_PUBLIC_KEY_4")
        XCTAssertEqual(result.directoryServerSdkKeyList[3].rootPublicKey, "MOCK_ROOT_PUBLIC_KEY_4")

        // Verify DINERS scheme details
        XCTAssertEqual(result.directoryServerSdkKeyList[4].scheme, "DINERS")
        XCTAssertEqual(result.directoryServerSdkKeyList[4].rid, "MOCK_RID_5")
        XCTAssertEqual(result.directoryServerSdkKeyList[4].publicKey, "MOCK_PUBLIC_KEY_5")
        XCTAssertEqual(result.directoryServerSdkKeyList[4].rootPublicKey, "MOCK_ROOT_PUBLIC_KEY_5")
    }
    
    // MARK: - Utility Tests
    
    /// Tests the return URL generation utility to verify it creates the correct
    /// redirect URL with the session token for the sandbox environment.
    func testReturnURLGenerationCreatesCorrectSandboxURL() {
        // Given
        let token = "testToken123"
        
        // When
        let url = api.returnURLString(sessionToken: token)
        
        // Then
        XCTAssertEqual("https://homologation-payment.payline.com/v2?token=\(token)", url)
    }
}
