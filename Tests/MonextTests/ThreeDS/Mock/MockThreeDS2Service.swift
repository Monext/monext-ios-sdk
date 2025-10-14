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
    private let accessQueue = DispatchQueue(label: "com.monext.MockThreeDS2Service.accessQueue", attributes: .concurrent)
    
    private var _didInitialize = false
    private var _transactionToReturn: ThreeDS_SDK.Transaction = MockTransaction()
    private var _warningsToReturn: [ThreeDS_SDK.Warning] = []
    
    // Configuration du mock
    private var shouldSucceed = true
    private var errorToThrow: Error?
    private var useAsyncBehavior = false
    private var initializationDelay: TimeInterval = 0.1
    
    var didInitialize: Bool {
        get {
            accessQueue.sync { _didInitialize }
        }
        set {
            accessQueue.async(flags: .barrier) { self._didInitialize = newValue }
        }
    }
    
    var transactionToReturn: ThreeDS_SDK.Transaction {
        get {
            accessQueue.sync { _transactionToReturn }
        }
        set {
            accessQueue.async(flags: .barrier) { self._transactionToReturn = newValue }
        }
    }
    
    var warningsToReturn: [ThreeDS_SDK.Warning] {
        get {
            accessQueue.sync { _warningsToReturn }
        }
        set {
            accessQueue.async(flags: .barrier) { self._warningsToReturn = newValue }
        }
    }
    
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomization: ThreeDS_SDK.UiCustomization?) throws {
        didInitialize = true
    }
    
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomizationMap: [String : ThreeDS_SDK.UiCustomization]?) throws {
        didInitialize = true
    }
    
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomizationMap: [String : ThreeDS_SDK.UiCustomization]?, success: @escaping @Sendable () -> (), failure: @escaping @Sendable (any Error) -> ()) {
        if useAsyncBehavior {
            DispatchQueue.global().asyncAfter(deadline: .now() + initializationDelay) { [weak self] in
                guard let self = self else { return }
                
                if self.shouldSucceed {
                    self.didInitialize = true
                    DispatchQueue.main.async {
                        success()
                    }
                } else {
                    let error = self.errorToThrow ?? NSError(domain: "MockError", code: 1, userInfo: nil)
                    DispatchQueue.main.async {
                        failure(error)
                    }
                }
            }
        } else {
            if shouldSucceed {
                didInitialize = true
                DispatchQueue.main.async {
                    success()
                }
            } else {
                let error = errorToThrow ?? NSError(domain: "MockError", code: 1, userInfo: nil)
                DispatchQueue.main.async {
                    failure(error)
                }
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
        accessQueue.async(flags: .barrier) {
            self.shouldSucceed = true
            self.initializationDelay = delay
            self.errorToThrow = nil
            self.useAsyncBehavior = async
        }
    }
    
    func configureForFailure(error: Error, delay: TimeInterval = 0.1, async: Bool = false) {
        accessQueue.async(flags: .barrier) {
            self.shouldSucceed = false
            self.errorToThrow = error
            self.initializationDelay = delay
            self.useAsyncBehavior = async
        }
    }
    
    func reset() {
        accessQueue.async(flags: .barrier) {
            self._didInitialize = false
            self.shouldSucceed = true
            self.errorToThrow = nil
            self.initializationDelay = 0.1
            self._warningsToReturn = []
            self.useAsyncBehavior = false
        }
    }
}
