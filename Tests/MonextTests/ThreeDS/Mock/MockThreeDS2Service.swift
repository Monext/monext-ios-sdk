//
//  MockThreeDS2Service.swift
//  Monext
//
//  Reworked to fix Swift concurrency sendability and main-actor capture issues.
//  Created by SDK Mobile on 24/07/2025.
//  Updated by Copilot on 2025-10-28.
//

import Foundation
@preconcurrency import ThreeDS_SDK
@testable import Monext

/// Boxes to wrap non-sendable callbacks so they can be captured safely in @Sendable closures.
/// Marked `@unchecked Sendable` because we intentionally bypass the compiler's Sendable checks:
/// we only forward calls to the underlying closures on the main queue.
final class CallbackBox: @unchecked Sendable {
    private let callback: () -> ()
    init(_ callback: @escaping () -> ()) { self.callback = callback }
    func callOnMain() { DispatchQueue.main.async { self.callback() } }
}

final class ErrorCallbackBox: @unchecked Sendable {
    private let callback: (any Error) -> ()
    init(_ callback: @escaping (any Error) -> ()) { self.callback = callback }
    func callOnMain(_ error: any Error) { DispatchQueue.main.async { self.callback(error) } }
}

/// Mock implementation of ThreeDS2Service suitable for tests.
/// - Avoids constructing SDK types that tests may not have access to.
/// - Provides thread-safe access to internal state via a concurrent queue with barrier writes.
/// - Uses CallbackBox / ErrorCallbackBox to safely capture non-Sendable callbacks from the protocol signature.
class MockThreeDS2Service: NSObject, ThreeDS2Service, @unchecked Sendable {
    private let accessQueue = DispatchQueue(label: "com.monext.MockThreeDS2Service.accessQueue", attributes: .concurrent)

    // Internal state
    private var _didInitialize: Bool = false
    private var _transactionToReturn: (any ThreeDS_SDK.Transaction)?
    private var _warningsToReturn: [ThreeDS_SDK.Warning] = []

    // Config for async behavior in tests
    private var shouldSucceed = true
    private var errorToThrow: Error?
    private var useAsyncBehavior = false
    private var initializationDelay: TimeInterval = 0.1
    
    override init() {
         super.init()
         // Provide a sensible default transaction so tests that don't customize the mock still work.
         self.transactionToReturn = MockTransaction()
     }

    // MARK: - Thread-safe accessors

    var didInitialize: Bool {
        get { accessQueue.sync { _didInitialize } }
        set { accessQueue.async(flags: .barrier, execute: { self._didInitialize = newValue }) }
    }

    var transactionToReturn: (any ThreeDS_SDK.Transaction)? {
        get { accessQueue.sync { _transactionToReturn } }
        set { accessQueue.async(flags: .barrier, execute: { self._transactionToReturn = newValue }) }
    }

    var warningsToReturn: [ThreeDS_SDK.Warning] {
        get { accessQueue.sync { _warningsToReturn } }
        set { accessQueue.async(flags: .barrier, execute: { self._warningsToReturn = newValue }) }
    }

    // MARK: - Initialize (synchronous variants)

    @available(*, deprecated, message: "Starting with protocol version 2.3.1, integrators should pass the UICustomization as a map.")
    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomization: ThreeDS_SDK.UiCustomization?) throws {
        let (shouldSucceedLocal, errorLocal) = accessQueue.sync { (self.shouldSucceed, self.errorToThrow) }
        if shouldSucceedLocal {
            accessQueue.async(flags: .barrier, execute: { self._didInitialize = true })
        } else {
            throw errorLocal ?? NSError(domain: "MockError", code: 1, userInfo: nil)
        }
    }

    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomizationMap: [String : ThreeDS_SDK.UiCustomization]?) throws {
        let (shouldSucceedLocal, errorLocal) = accessQueue.sync { (self.shouldSucceed, self.errorToThrow) }
        if shouldSucceedLocal {
            accessQueue.async(flags: .barrier, execute: { self._didInitialize = true })
        } else {
            throw errorLocal ?? NSError(domain: "MockError", code: 1, userInfo: nil)
        }
    }

    // MARK: - Initialize (async variant matching protocol signature)

    func initialize(_ configParameters: ConfigParameters, locale: String?, uiCustomizationMap: [String : ThreeDS_SDK.UiCustomization]?, success: @escaping () -> (), failure: @escaping (any Error) -> ()) {
        // Wrap the non-Sendable closures in unchecked Sendable boxes so they can be captured by @Sendable closures.
        let successBox = CallbackBox(success)
        let failureBox = ErrorCallbackBox(failure)

        // The work closure is explicitly @Sendable and captures only Sendable or @unchecked Sendable things.
        let work: @Sendable () -> Void = { [weak self, successBox, failureBox] in
            guard let self = self else { return }
            // Read the desired configuration atomically
            let (shouldSucceedLocal, errorLocal) = self.accessQueue.sync { (self.shouldSucceed, self.errorToThrow) }

            if shouldSucceedLocal {
                // update state through the thread-safe accessor
                self.didInitialize = true
                // call success on main via the boxed wrapper
                successBox.callOnMain()
            } else {
                let error = errorLocal ?? NSError(domain: "MockError", code: 1, userInfo: nil)
                failureBox.callOnMain(error)
            }
        }

        if useAsyncBehavior {
            // DispatchQueue.global().asyncAfter expects a @Sendable closure; `work` is @Sendable so this is safe.
            DispatchQueue.global().asyncAfter(deadline: .now() + initializationDelay, execute: work)
        } else {
            // Call synchronously on the current queue
            work()
        }
    }

    // MARK: - Transaction / Warnings / SDK Info / Version / Cleanup

    func createTransaction(directoryServerId: String, messageVersion: String?) throws -> any ThreeDS_SDK.Transaction {
        guard didInitialize else {
            throw ThreeDS2Error.SDKNotInitialized(message: "SDK not initialized", cause: nil)
        }
        if let tx = transactionToReturn {
            return tx
        } else {
            // Avoid constructing SDK Transaction types that may be unavailable in test target.
            throw ThreeDS2Error.SDKRuntime(message: "No transaction configured on MockThreeDS2Service", errorCode: nil, cause: nil)
        }
    }

    func getWarnings() throws -> [ThreeDS_SDK.Warning] {
        guard didInitialize else {
            throw ThreeDS2Error.SDKNotInitialized(message: "SDK not initialized", cause: nil)
        }
        return warningsToReturn
    }

    func getSDKVersion() throws -> String {
        guard didInitialize else {
            throw ThreeDS2Error.SDKNotInitialized(message: "SDK not initialized", cause: nil)
        }
        return "mock-version-1.0.0"
    }

    func getSDKInfo() throws -> ThreeDS_SDK.SDKInfo {
        guard didInitialize else {
            throw ThreeDS2Error.SDKNotInitialized(message: "SDK not initialized", cause: nil)
        }
        // Tests typically cannot construct SDKInfo; throw an SDKRuntime to let tests handle it.
        throw ThreeDS2Error.SDKRuntime(message: "SDKInfo construction unavailable in tests", errorCode: nil, cause: nil)
    }

    func cleanup() throws {
        guard didInitialize else {
            throw ThreeDS2Error.SDKNotInitialized(message: "SDK not initialized", cause: nil)
        }
        didInitialize = false
    }

    // MARK: - Configuration Methods for Testing

    func configureForSuccess(delay: TimeInterval = 0.1, async: Bool = false) {
        accessQueue.async(flags: .barrier, execute: {
            self.shouldSucceed = true
            self.initializationDelay = delay
            self.errorToThrow = nil
            self.useAsyncBehavior = async
        })
    }

    func configureForFailure(error: Error, delay: TimeInterval = 0.1, async: Bool = false) {
        accessQueue.async(flags: .barrier, execute: {
            self.shouldSucceed = false
            self.errorToThrow = error
            self.initializationDelay = delay
            self.useAsyncBehavior = async
        })
    }

    func reset() {
        accessQueue.async(flags: .barrier, execute: {
            self._didInitialize = false
            self.shouldSucceed = true
            self.errorToThrow = nil
            self.initializationDelay = 0.1
            self._warningsToReturn = []
            self._transactionToReturn = nil
            self.useAsyncBehavior = false
        })
    }
}
