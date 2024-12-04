//
//  BaseAPITestCase.swift
//  Monext
//
//  Created by SDK Mobile on 31/07/2025.
//
import Foundation
import XCTest
@testable import Monext

class BaseAPITestCase: XCTestCase {
    var api: PaymentAPIProtocol!
    
    lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }()
    
    /// Setup de base sans @MainActor
    func setupAPI(useMockAPI: Bool = false) {
        api = PaymentAPI(session: session, config: .init(), environment: .sandbox)
    }
    
    /// Création du SessionStateStore (à appeler dans les tests)
    @MainActor
    func createSessionStateStore() -> SessionStateStore {
        let appearance = Appearance()
        let applePayConfig = ApplePayConfiguration()
        
        return SessionStateStore(
            paymentAPI: api,
            appearance: appearance,
            config: .init(),
            applePayConfiguration: applePayConfig
        )
    }
    
    /// Sets up a mock response for a specific token and endpoint
    /// - Parameters:
    ///   - token: The session token
    ///   - endpoint: The API endpoint
    ///   - jsonFileName: Name of the JSON file containing mock data
    ///   - statusCode: HTTP status code to return (default: 200)
    func setupMockResponse(
        for token: String,
        endpoint: String,
        jsonFileName: String,
        statusCode: Int = 200
    ) async {
        guard api is PaymentAPI else {
            XCTFail("API should be of type PaymentAPI for mock setup")
            return
        }
        
        let mockData = loadTestJSON(named: jsonFileName)
        let expectedURL = "https://\(api.getEnvironment().host)/services/token/\(token)/\(endpoint)"
        
        await MockURLProtocol.setHandler({ request in
            XCTAssertEqual(
                request.url?.absoluteString,
                expectedURL,
                "Request URL should match expected endpoint"
            )
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            
            return (response, mockData)
        })
    }
    
    // MARK: - Mock Response Management
    
    /// Clears all mock responses to ensure clean state between tests
    /// Uses expectation pattern to properly handle async operations in test lifecycle
    func clearMockResponses() {
        let expectation = expectation(description: "Clear mock responses")
        
        Task {
            await MockURLProtocol.clearHandler()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    /// Clears mock responses asynchronously (useful for async test cleanup)
    func clearMockResponsesAsync() async {
        await MockURLProtocol.clearHandler()
    }
}
