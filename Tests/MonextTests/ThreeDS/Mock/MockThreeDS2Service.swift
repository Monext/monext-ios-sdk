//
//  MockThreeDS2Service.swift
//  Monext
//
//  Created by SDK Mobile on 24/07/2025.
//

import Foundation
@preconcurrency import ThreeDS_SDK
@testable import Monext

class MockThreeDS2Service: NSObject, ThreeDS2Service, @unchecked Sendable {
    var didInitialize = false
    var transactionToReturn: ThreeDS_SDK.Transaction = MockTransaction()
    var warningsToReturn: [ThreeDS_SDK.Warning] = []
    
    // Configuration du mock
    var shouldSucceed = true
    var errorToThrow: Error?
    var useAsyncBehavior = false
    var initializationDelay: TimeInterval = 0.1
    
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomization: ThreeDS_SDK.UiCustomization?) throws {
        didInitialize = true
    }
    
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomizationMap: [String : ThreeDS_SDK.UiCustomization]?) throws {
        didInitialize = true
    }
    
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomizationMap: [String : ThreeDS_SDK.UiCustomization]?, success: @escaping @Sendable () -> (), failure: @escaping @Sendable (any Error) -> ()) {
        print("Mock initialize called")
        if useAsyncBehavior {
            DispatchQueue.main.asyncAfter(deadline: .now() + initializationDelay) { [weak self] in
                guard let self = self else { return }
                
                if self.shouldSucceed {
                    print("Mock initialization succeeded asynchronously")
                    self.didInitialize = true
                    success()
                } else {
                    let error = self.errorToThrow ?? NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock initialization failed"])
                    print("Mock initialization failed asynchronously")
                    failure(error)
                }
            }
        } else {
            if shouldSucceed {
                print("Mock initialization succeeded synchronously")
                didInitialize = true
                success()
            } else {
                let error = errorToThrow ?? NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock initialization failed"])
                print("Mock initialization failed synchronously")
                failure(error)
            }
        }
    }
    
    func createTransaction(directoryServerId: String, messageVersion: String?) throws -> any ThreeDS_SDK.Transaction {
        guard didInitialize else {
            throw ThreeDS2Error.SDKNotInitialized(message: "SDK not initialized", cause: nil)
        }
        return transactionToReturn
    }
    
    func getWarnings() throws -> [ThreeDS_SDK.Warning] {
        return warningsToReturn
    }
    
    func getSDKVersion() throws -> String {
        return "mock-version-1.0.0"
    }
    
    /// It is impossible to build SDKInfo because the constructor is blocked by Netcetera.
    func getSDKInfo() throws -> ThreeDS_SDK.SDKInfo {
        fatalError()
    }
    
    func cleanup() throws {
        didInitialize = false
    }
    
    // MARK: - Configuration Methods for Testing
    
    func configureForSuccess(delay: TimeInterval = 0.1, async: Bool = false) {
        shouldSucceed = true
        initializationDelay = delay
        errorToThrow = nil
        useAsyncBehavior = async
    }
    
    func configureForFailure(error: Error, delay: TimeInterval = 0.1, async: Bool = false) {
        shouldSucceed = false
        errorToThrow = error
        initializationDelay = delay
        useAsyncBehavior = async
    }
    
    func reset() {
        didInitialize = false
        shouldSucceed = true
        errorToThrow = nil
        initializationDelay = 0.1
        warningsToReturn = []
        useAsyncBehavior = false
    }
}
