//
//  ThreeDS2ManagerTests.swift
//  MonextTests
//
//  Created on 2025-07-16
//

import XCTest
@testable import Monext
@preconcurrency import ThreeDS_SDK

final class ThreeDS2ManagerTests: XCTestCase {
    
    private var mockService: MockThreeDS2Service!
    private var mockPaymentAPI: PaymentAPIProtocol!
    
    override func setUp() {
        super.setUp()
        mockService = MockThreeDS2Service()
        mockPaymentAPI = MockPaymentAPI()
    }
    
    override func tearDown() {
        mockService.reset()
        mockService = nil
        super.tearDown()
    }
    
    func testSimpleInitialization() async throws {
        // Arrange
        mockService.configureForSuccess()
        
        let manager = await ThreeDS2Manager(threeDS2Service: mockService, paymentAPI: mockPaymentAPI)
        
        // Act
        try await manager.initialize(sessionToken: "fake_token", locale: "EN", cardNetworkName: "VISA")
        
        // Assert
        let isInitialized = await manager.isInitialized
        XCTAssertTrue(isInitialized, "Le manager devrait être initialisé")
    }
    
    func testSDKInitializationAndTransactionData() async throws {
        // Arrange
        mockService.configureForSuccess(delay: 0.05, async: true)
        
        let mockPaymentAPI = MockPaymentAPI()
        // Le MockPaymentAPI a déjà VISA configuré par défaut
        
        let manager = await ThreeDS2Manager(threeDS2Service: mockService, paymentAPI: mockPaymentAPI)
        
        // Act & Assert - Initialisation
        try await manager.initialize(sessionToken: "fake_token", locale: "EN", cardNetworkName: "VISA")
        
        // Attend un peu pour que l'initialisation asynchrone se termine
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
        
        // Vérifie que l'initialisation a réussi
        let isInitialized = await manager.isInitialized
        XCTAssertTrue(isInitialized, "Le manager devrait être initialisé")
        
        // Act & Assert - Création de transaction
        let transaction = try await manager.createTransaction()
        let authParams = try transaction.getAuthenticationRequestParameters()
        
        // Récupère les valeurs
        let sdkTransactionId = authParams.getSDKTransactionId()
        let deviceData = authParams.getDeviceData()
        let sdkAppID = authParams.getSDKAppID()
        let sdkReferenceNumber = authParams.getSDKReferenceNumber()
        let sdkEphemeralPublicKey = authParams.getSDKEphemeralPublicKey()
        let messageVersion = authParams.getMessageVersion()
        
        // Assert
        XCTAssertEqual(sdkTransactionId, "mock-transaction-id")
        XCTAssertEqual(deviceData, "mock-device-data")
        XCTAssertEqual(sdkAppID, "mock-app-id")
        XCTAssertEqual(sdkReferenceNumber, "mock-reference-number")
        XCTAssertEqual(sdkEphemeralPublicKey, "mock-ephemeral-key")
        XCTAssertEqual(messageVersion, "2.1.0")
        
        // Cleanup
        await manager.closeTransaction()
    }
    
    func testCreateTransactionWithoutInitialization() async throws {
        // Arrange
        let manager = await ThreeDS2Manager(threeDS2Service: mockService, paymentAPI: mockPaymentAPI)
        
        // Act & Assert
        do {
            _ = try await manager.createTransaction()
            XCTFail("La création de transaction aurait dû échouer sans initialisation")
        } catch {
            XCTAssertNotNil(error, "Une erreur aurait dû être levée")
            print("Erreur capturée : \(error)")
        }
    }
    
    @MainActor
    func testGetSchemeForCardCode() {
        // Arrange
        let manager = ThreeDS2Manager(threeDS2Service: mockService, paymentAPI: mockPaymentAPI)
        
        // Test pour chaque cas valide
        XCTAssertNoThrow(try {
            let cbScheme = try manager.getSchemeForCardCode("CB")
            XCTAssertTrue(cbScheme.encryptionKeyValue == Scheme.cb().encryptionKeyValue)
            
            let visaScheme = try manager.getSchemeForCardCode("VISA")
            XCTAssertTrue(visaScheme.encryptionKeyValue == Scheme.visa().encryptionKeyValue)
            
            let mastercardScheme = try manager.getSchemeForCardCode("MASTERCARD")
            XCTAssertTrue(mastercardScheme.encryptionKeyValue == Scheme.mastercard().encryptionKeyValue)
            
            let amexScheme = try manager.getSchemeForCardCode("AMEX")
            XCTAssertTrue(amexScheme.encryptionKeyValue == Scheme.amex().encryptionKeyValue)
        }())
    }
    
    @MainActor
    func testGetSchemeForCardCodeInvalid() {
        // Arrange
        let manager = ThreeDS2Manager(threeDS2Service: mockService, paymentAPI: mockPaymentAPI)
        
        // Test pour un code non supporté
        XCTAssertThrowsError(try manager.getSchemeForCardCode("DISCOVER"), "Expected unsupported card code error") { error in
            // Vérifiez le type de l'erreur, si nécessaire
            guard let schemeError = error as? SchemeError else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            
            // Vérifiez que l'erreur est bien celle attendue
            XCTAssertEqual(schemeError, SchemeError.unsupportedCardCode("DISCOVER"))
        }
    }
}
